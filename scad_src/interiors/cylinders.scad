/*
 * Cylinder interior (holes + optional raised floor).
 *
 * Expects core geometry from `scad_src/core/gridfinity_tray_core.scad`.
 */

// True hole radius incl. fit clearance (what must not be clipped by walls/corners)
hole_radius = (cylinder_diameter / 2) + (holder_clearance / 2);

// Center-to-center spacing between holes (includes clearance + min wall)
holder_spacing = (cylinder_diameter + holder_clearance) + min_wall_between;

// Generate hex grid with specific orientation
// swap_axes: if true, tight spacing is horizontal (good for tall containers)
// x_offset, y_offset: shift pattern for optimization (0 to 0.5 range)
function generate_hex_pattern(avail_w, avail_h, spacing, swap_axes, x_off, y_off) =
    let(
        tight = spacing * sqrt(3) / 2,
        col_spacing = swap_axes ? tight : spacing,
        row_spacing = swap_axes ? spacing : tight,
        
        num_cols = ceil(avail_w / col_spacing) + 1,
        num_rows = ceil(avail_h / row_spacing) + 1,
        
        positions = [for (row = [0:num_rows])
                        for (col = [0:num_cols])
                            let(
                                // Hex offset alternates based on axis orientation
                                offset = swap_axes 
                                    ? (col % 2 == 1 ? spacing / 2 : 0)  // Y offset for alternate columns
                                    : (row % 2 == 1 ? spacing / 2 : 0), // X offset for alternate rows
                                x = col * col_spacing + (swap_axes ? 0 : offset) + x_off * col_spacing,
                                y = row * row_spacing + (swap_axes ? offset : 0) + y_off * row_spacing
                            )
                            if (x >= 0 && x <= avail_w && y >= 0 && y <= avail_h)
                                [x, y]
                    ]
    ) positions;

// Try hex configurations and return the best one (optimized - fewer configs)
function find_best_hex_config(avail_w, avail_h, spacing) =
    let(
        // Try both orientations with key offsets only
        configs = [
            [false, 0, 0], [false, 0.5, 0], [false, 0, 0.5], [false, 0.5, 0.5],
            [true, 0, 0], [true, 0.5, 0], [true, 0, 0.5], [true, 0.5, 0.5]
        ],
        counts = [for (c = configs) 
                    len(generate_hex_pattern(avail_w, avail_h, spacing, c[0], c[1], c[2]))
                 ],
        max_count = max(counts),
        best_idx = search(max_count, counts)[0]
    )
    configs[best_idx];

// Generate grid positions
function generate_grid_positions(avail_w, avail_h, spacing) =
    let(
        num_cols = max(1, floor(avail_w / spacing) + 1),
        num_rows = max(1, floor(avail_h / spacing) + 1)
    )
    [for (row = [0:num_rows-1])
        for (col = [0:num_cols-1])
            let(x = col * spacing, y = row * spacing)
            if (x <= avail_w && y <= avail_h) [x, y]
    ];

// Center positions within usable area
function center_positions(positions, avail_w, avail_h, edge_dist) =
    len(positions) == 0 ? [] :
    let(
        xs = [for (p = positions) p[0]],
        ys = [for (p = positions) p[1]],
        min_x = min(xs),
        max_x = max(xs),
        min_y = min(ys),
        max_y = max(ys),
        array_w = max_x - min_x,
        array_h = max_y - min_y,
        off_x = edge_dist + (avail_w - array_w) / 2 - min_x,
        off_y = edge_dist + (avail_h - array_h) / 2 - min_y
    )
    [for (p = positions) [p[0] + off_x, p[1] + off_y]];

// Generate valid cylinder centers with optimal packing
function generate_valid_positions() =
    let(
        // When a tray wall exists, it doesn't need to “contain” the holder rim.
        // We only require the *hole* circle to fit fully inside the tray opening.
        // (Rim walls can merge into the tray wall and will be clipped by it.)
        min_edge_dist = hole_radius,
        avail_w = opening_width - 2 * min_edge_dist,
        avail_h = opening_depth - 2 * min_edge_dist
    )
    assert(
        avail_w >= 0 && avail_h >= 0,
        str(
            "No room for holders: cylinder_diameter=", cylinder_diameter,
            "mm (clearance=", holder_clearance, "mm) is too large for opening ",
            opening_width, "×", opening_depth, "mm. Increase gridx/gridy, reduce tray_wall_thickness, disable tray walls, or disable holders."
        )
    )
    let(
        // Grid positions (preferred when counts are equal)
        grid_positions = generate_grid_positions(avail_w, avail_h, holder_spacing),
        
        // Find best hex configuration
        best_config = find_best_hex_config(avail_w, avail_h, holder_spacing),
        hex_positions = generate_hex_pattern(avail_w, avail_h, holder_spacing, 
                                             best_config[0], best_config[1], best_config[2]),
        
        // Only use hex if it fits MORE cylinders (prefer grid when equal)
        use_hex = packing_mode != "grid" && len(hex_positions) > len(grid_positions),
        selected = use_hex ? hex_positions : grid_positions,

        // Center within the opening rectangle (then filter against rounded corners)
        centered = center_positions(selected, avail_w, avail_h, min_edge_dist),
        valid = [
            for (p = centered)
                if (circle_fits_in_rounded_rect(p[0], p[1], opening_width, opening_depth, opening_corner_r, hole_radius))
                    p
        ]
    )
    len(valid) > 0 ? valid : [[opening_width/2, opening_depth/2]];

function bottle_positions() = generate_valid_positions();

function holder_outer_r_top() = ((cylinder_diameter / 2) + (holder_clearance / 2)) + holder_rim_thickness;
function holder_outer_r_bottom() = holder_outer_r_top() + holder_rim_taper;
function holder_hole_r() = (cylinder_diameter / 2) + (holder_clearance / 2);

// Generate validated and centered cylinder positions (skip entirely for empty tray/bin)
positions = enable_holders ? bottle_positions() : [];

module build_holders() {
    if (!enable_holders) {
        // Empty tray/bin mode
    } else {
        // Holder rims with holes - only clip these if wall is enabled
        clip_width = enable_tray_wall ? wall_inner_width : total_width;
        clip_depth = enable_tray_wall ? wall_inner_depth : total_depth;
        clip_radius = enable_tray_wall ? max(0, BASE_OUTSIDE_RADIUS - tray_wall_thickness) : BASE_OUTSIDE_RADIUS;
        
        // Small overlap to ensure proper boolean union with base (manifold requirement)
        base_overlap = 0.1;
        // Clip only needs to cover the holder Z-range; keeping this small avoids preview artifacts.
        holder_clip_h = holder_start_z + holder_h_total() + 6;

        // Force CGAL for this intersection so preview matches render.
        render() intersection() {
            difference() {
                // Holder rim solids - tapered outer, extend slightly into base
                for_each_position(z = holder_start_z - base_overlap)
                    cylinder(holder_h_total() + base_overlap, holder_outer_r_bottom(), holder_outer_r_top());
                
                // Cut straight holes through holders
                for_each_position(z = holder_start_z - base_overlap - 0.1)
                    cylinder(holder_h_total() + base_overlap + 0.2, holder_hole_r(), holder_hole_r());
            }
            // Clip holder rims to fit inside wall
            translate([0, 0, -1])
            linear_extrude(holder_clip_h)
            rounded_rect_2d(clip_width, clip_depth, clip_radius);
        }
    }
}

module build_raised_floor() {
    // Raised floor to fill empty space between holders
    if (enable_raised_floor) {
        // Floor height from holder floor (cap to rim height only when holders exist)
        floor_height = enable_holders ? min(raised_floor_height, holder_rim_height) : raised_floor_height;
        // Actual holder floor Z (where objects sit, after recess)
        holder_floor_z_local = holder_floor_z();
        
        // Floor dimensions - fit inside wall if enabled
        floor_width = enable_tray_wall ? wall_inner_width : total_width;
        floor_depth = enable_tray_wall ? wall_inner_depth : total_depth;
        floor_radius = enable_tray_wall ? max(0, BASE_OUTSIDE_RADIUS - tray_wall_thickness) : BASE_OUTSIDE_RADIUS;
        
        if (enable_holders) {
            // Force CGAL evaluation so preview matches render (web customizers).
            render() difference() {
                // Solid floor block - starts at holder floor
                translate([0, 0, holder_floor_z_local])
                linear_extrude(floor_height)
                rounded_rect_2d(floor_width, floor_depth, floor_radius);
                
                // Cut out holder footprints - slightly larger than the rim to avoid coincident faces
                floor_clearance = 0.05;  // Small clearance to avoid manifold issues
                for_each_position(base_xy = [start_offset_x, start_offset_y], z = holder_floor_z_local - 0.1)
                    cylinder(
                        floor_height + 0.2, 
                        holder_outer_r_bottom() + floor_clearance, 
                        holder_outer_r_top() + floor_clearance
                    );
            }
        } else {
            // Empty tray/bin mode: raised floor is a solid slab (no holes)
            render()
            translate([0, 0, holder_floor_z_local])
            linear_extrude(floor_height)
            rounded_rect_2d(floor_width, floor_depth, floor_radius);
        }
    }
}


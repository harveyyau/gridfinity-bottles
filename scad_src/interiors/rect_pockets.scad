/*
 * Rectangular pocket interior (pocket walls + optional raised floor).
 *
 * Expects core geometry from `scad_src/core/gridfinity_tray_core.scad`.
 */

pocket_inner_w = object_width + pocket_clearance_xy;
pocket_inner_d = object_depth + pocket_clearance_xy;
pocket_outer_w = pocket_inner_w + pocket_wall_thickness * 2;
pocket_outer_d = pocket_inner_d + pocket_wall_thickness * 2;

pocket_inner_r_req = (pocket_inner_corner_style == "sharp") ? 0 : pocket_corner_radius;
pocket_inner_r = min(pocket_inner_r_req, min(pocket_inner_w, pocket_inner_d) / 2);
pocket_outer_r = min(pocket_inner_r + pocket_wall_thickness, min(pocket_outer_w, pocket_outer_d) / 2);

function pocket_fits_in_opening(cx, cy) =
    let(hw = pocket_outer_w / 2, hd = pocket_outer_d / 2)
    circle_fits_in_rounded_rect(cx - hw, cy - hd, opening_width, opening_depth, opening_corner_r, 0) &&
    circle_fits_in_rounded_rect(cx + hw, cy - hd, opening_width, opening_depth, opening_corner_r, 0) &&
    circle_fits_in_rounded_rect(cx - hw, cy + hd, opening_width, opening_depth, opening_corner_r, 0) &&
    circle_fits_in_rounded_rect(cx + hw, cy + hd, opening_width, opening_depth, opening_corner_r, 0);

function rect_pocket_positions() =
    let(
        avail_w = opening_width - pocket_outer_w,
        avail_h = opening_depth - pocket_outer_d,
        spacing_x = pocket_outer_w + min_wall_between,
        spacing_y = pocket_outer_d + min_wall_between
    )
    // Graceful fallback: if the pocket is too large for the opening, avoid crashing and
    // place a single centered pocket. It will be clipped by the tray opening/walls.
    (avail_w < 0 || avail_h < 0) ?
        let(_warn = echo(str(
            "WARNING: Pocket does not fit the tray opening; placing 1 centered pocket (will be clipped). ",
            "object_width=", object_width, "mm object_depth=", object_depth, "mm (clearance=", pocket_clearance_xy, "mm); opening=", opening_width, "×", opening_depth, "mm."
        )))
        [[opening_width/2, opening_depth/2]]
    :
    let(
        cols = max(1, floor(avail_w / spacing_x) + 1),
        rows = max(1, floor(avail_h / spacing_y) + 1),
        used_w = pocket_outer_w + (cols - 1) * spacing_x,
        used_h = pocket_outer_d + (rows - 1) * spacing_y,
        margin_x = max(0, (opening_width - used_w) / 2),
        margin_y = max(0, (opening_depth - used_h) / 2),
        xs = [for (c = [0:cols-1]) margin_x + pocket_outer_w/2 + c * spacing_x],
        ys = [for (r = [0:rows-1]) margin_y + pocket_outer_d/2 + r * spacing_y],
        raw = [for (y = ys) for (x = xs) [x, y]],
        valid = [for (p = raw) if (pocket_fits_in_opening(p[0], p[1])) p]
    )
    len(valid) > 0 ? valid : [[opening_width/2, opening_depth/2]];

// Generate validated and centered pocket positions (skip entirely for empty tray/bin)
positions = enable_holders ? rect_pocket_positions() : [];

module build_holders() {
    if (!enable_holders) {
        // Empty tray/bin mode
    } else {
        // Pocket walls - only clip these if wall is enabled
        clip_width = enable_tray_wall ? wall_inner_width : total_width;
        clip_depth = enable_tray_wall ? wall_inner_depth : total_depth;
        clip_radius = enable_tray_wall ? max(0, BASE_OUTSIDE_RADIUS - tray_wall_thickness) : BASE_OUTSIDE_RADIUS;

        // Small overlap to ensure proper boolean union with base (manifold requirement)
        base_overlap = 0.1;
        // Clip only needs to cover the pocket Z-range; keeping this small avoids preview artifacts.
        pocket_clip_h = holder_start_z + holder_h_total() + 6;

        // Force CGAL for this intersection so preview matches render.
        render() intersection() {
            difference() {
                // Pocket wall solids
                for_each_position(z = holder_start_z - base_overlap)
                    linear_extrude(holder_h_total() + base_overlap)
                    rounded_rect_2d(pocket_outer_w, pocket_outer_d, pocket_outer_r);

                // Pocket cavity
                for_each_position(z = holder_start_z - base_overlap - 0.1)
                    linear_extrude(holder_h_total() + base_overlap + 0.2)
                    rounded_rect_2d(pocket_inner_w, pocket_inner_d, pocket_inner_r);
            }

            // Clip pocket walls to fit inside wall
            translate([0, 0, -1])
            linear_extrude(pocket_clip_h)
            rounded_rect_2d(clip_width, clip_depth, clip_radius);
        }
    }
}

module build_raised_floor() {
    // Raised floor to fill empty space between pockets
    if (enable_raised_floor) {
        // Floor height from pocket floor (cap to wall height only when pockets exist)
        floor_height = enable_holders ? min(raised_floor_height, holder_rim_height) : raised_floor_height;
        // Actual pocket floor Z (where objects sit, after recess)
        holder_floor_z_local = holder_floor_z();

        // Floor dimensions - fit inside wall if enabled
        floor_width = enable_tray_wall ? wall_inner_width : total_width;
        floor_depth = enable_tray_wall ? wall_inner_depth : total_depth;
        floor_radius = enable_tray_wall ? max(0, BASE_OUTSIDE_RADIUS - tray_wall_thickness) : BASE_OUTSIDE_RADIUS;

        if (enable_holders) {
            render() difference() {
                // Solid floor block - starts at pocket floor
                translate([0, 0, holder_floor_z_local])
                linear_extrude(floor_height)
                rounded_rect_2d(floor_width, floor_depth, floor_radius);

                // Remove the pocket footprints so the floor doesn't intersect pocket walls
                floor_clearance = 0.05;
                for_each_position(base_xy = [start_offset_x, start_offset_y], z = holder_floor_z_local - 0.1)
                    linear_extrude(floor_height + 0.2)
                    rounded_rect_2d(
                        pocket_outer_w + 2*floor_clearance,
                        pocket_outer_d + 2*floor_clearance,
                        pocket_outer_r + floor_clearance
                    );
            }
        } else {
            // Empty tray/bin mode: raised floor is a solid slab (no cutouts)
            render()
            translate([0, 0, holder_floor_z_local])
            linear_extrude(floor_height)
            rounded_rect_2d(floor_width, floor_depth, floor_radius);
        }
    }
}


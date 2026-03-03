ARG UBUNTU_VERSION=22.04

FROM --platform=linux/amd64 ubuntu:${UBUNTU_VERSION}

ARG BAMBU_TAG=v02.05.00.67
ARG BAMBU_APPIMAGE=Bambu_Studio_linux_fedora-v02.05.00.66.AppImage
ARG BAMBU_URL=https://github.com/bambulab/BambuStudio/releases/download/${BAMBU_TAG}/${BAMBU_APPIMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
    libasound2 \
    libdbus-1-3 \
    libdrm2 \
    libfontconfig1 \
    libfreetype6 \
    libgbm1 \
    libglib2.0-0 \
    libgcc-s1 \
    libnss3 \
    libpango-1.0-0 \
    libpangoft2-1.0-0 \
    libgl1 \
    libegl1 \
    libopengl0 \
    libwayland-client0 \
    libwayland-cursor0 \
    libwayland-egl1 \
    libgtk-3-0 \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    libsoup2.4-1 \
    libwebkit2gtk-4.0-37 \
    libosmesa6 \
    libstdc++6 \
    libx11-6 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxkbcommon0 \
    libxkbcommon-x11-0 \
    libxrandr2 \
    libxrender1 \
    libxcb1 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -L --fail -o /tmp/BambuStudio.AppImage "${BAMBU_URL}" \
  && chmod +x /tmp/BambuStudio.AppImage \
  # Docker Desktop's x86 emulation binfmt rules expect zeroed ABI/padding bytes.
  # This AppImage uses custom values (harmless on real x86 Linux, but breaks exec under emulation),
  # so we zero bytes 8-15 of e_ident before executing it.
  && printf "\0\0\0\0\0\0\0\0" | dd of=/tmp/BambuStudio.AppImage bs=1 seek=8 conv=notrunc status=none \
  && /tmp/BambuStudio.AppImage --appimage-extract \
  && mv squashfs-root /opt/bambu \
  && rm -f /tmp/BambuStudio.AppImage \
  && ln -s /opt/bambu/AppRun /usr/local/bin/bambu-studio

# Avoid requiring an X server for CLI use.
ENV QT_QPA_PLATFORM=offscreen

WORKDIR /work
ENTRYPOINT ["bambu-studio"]

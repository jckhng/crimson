FROM debian:bookworm-slim

ARG ZIG_VERSION=0.16.0
ARG DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture arm64 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        file \
        pkg-config \
        xz-utils \
        zip \
        libc6-dev-arm64-cross \
        libsdl2-dev:arm64 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz" \
        | tar -xJ -C /opt \
    && ln -s "/opt/zig-x86_64-linux-${ZIG_VERSION}/zig" /usr/local/bin/zig

ENV PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig
ENV C_INCLUDE_PATH=/usr/include:/usr/include/aarch64-linux-gnu:/usr/include/SDL2
ENV ZIG_GLOBAL_CACHE_DIR=/work/crimson-zig/.zig-cache-global
ENV ZIG_LOCAL_CACHE_DIR=/work/crimson-zig/.zig-cache

WORKDIR /work

CMD ["bash", "-lc", "cd crimson-zig && zig build --prefix zig-out-aarch64 window -Dtarget=aarch64-linux-gnu.2.36 -Dplatform=sdl2 -Dopengl_version=gles_2 -Dlinkage=dynamic -Doptimize=ReleaseFast && file zig-out-aarch64/bin/crimson-zig-window"]

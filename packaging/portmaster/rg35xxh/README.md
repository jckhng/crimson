# Crimsonland PortMaster

Native Zig PortMaster package for Crimsonland. This downstream handheld build
keeps the upstream rewrite intact where possible, but adds controller-first
menus, compact 640x480 presentation fixes, and twin-stick gamepad controls for
small Linux handhelds.

The current release package is `aarch64` only and has been tested on RG35XX-H
with muOS. It uses raylib's SDL2 backend with GLES2 and dynamic raylib linkage.
The original Crimsonland game archives are not included in public release zips;
users must provide their own data files.

Thanks to banteg for this faithful rewrite of Crimsonland.
Modded for handhelds: jckhng
Thanks to NotYerAvgPorter for testing.

## Required Files

Copy original Crimsonland data into `crimson/assets/` after installing the port:

- `crimson.paq`
- `sfx.paq`

Music is optional. Use either:

- `music.paq`
- loose GOG music files under `crimson/assets/music/*.ogg`

The game can launch without music. If `sfx.paq` is present, sound effects still
work when music files are missing.

## Controls

| Button | Action |
|--|--|
| D-pad / Left stick | Move menu selection / move player |
| A | Confirm / fire with current aim |
| B | Cancel / back / pause menu back |
| X | Backspace on high-score name entry |
| Y | Open perk picker when perks are available |
| L1 / L2 | Reload |
| Right stick | Aim; fire while pushed |
| R1 / R2 | Pointer click fallback |
| Start | Confirm / start |
| Select / Back | Cancel / back |

Keyboard fallback for desktop testing: arrows, Enter/Space, Esc, WASD, `r`,
Backspace.

## Compile

Build the native aarch64 executable with Zig, SDL2, GLES2, and dynamic raylib:

```sh
cd path/to/crimson/crimson-zig
PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig \
C_INCLUDE_PATH=/usr/include:/usr/include/aarch64-linux-gnu:/usr/include/SDL2 \
zig build --prefix zig-out-aarch64 window \
  -Dtarget=aarch64-linux-gnu.2.36 \
  -Dplatform=sdl2 \
  -Dopengl_version=gles_2 \
  -Dlinkage=dynamic \
  -Doptimize=ReleaseFast
```

The executable is:

```text
crimson-zig/zig-out-aarch64/bin/crimson-zig-window
```

The dynamic ARM64 `libraylib.so` must be packaged under:

```text
crimson/libs.aarch64/libraylib.so
```

The launcher already searches that directory through `LD_LIBRARY_PATH`.

## Package

The source package scaffold lives at:

```text
packaging/portmaster/rg35xxh/
  crimson.sh
  crimson/
    crimson.gptk
    port.json
    README.md
    gameinfo.xml
    THIRD_PARTY_NOTICES.md
    assets/
    runtime/
    controls/
    libs.aarch64/
```

For PortMaster autoinstall, the zip must contain the contents of this staging
folder, not the staging folder itself. The root of the zip should look like:

```text
crimson.sh
crimson/
  crimson.aarch64
  libs.aarch64/libraylib.so
  assets/
  runtime/
  controls/
  crimson.gptk
  port.json
  README.md
  gameinfo.xml
  THIRD_PARTY_NOTICES.md
```

This is easy to get wrong. If the zip root is
`rg35xxh/crimson.sh` or `roms/ports/crimson.sh`, PortMaster autoinstall will
not install the port in the expected layout.

The helper script stages a package from a built binary:

```sh
scripts/portmaster/build_zig_aarch64_bundle.sh \
  --binary crimson-zig/zig-out-aarch64/bin/crimson-zig-window \
  --out-dir artifacts/portmaster
```

Use `--assets-dir` only for private device testing. Public zips should ship
with an empty `crimson/assets/` directory.

## Runtime Layout

The launcher resolves the PortMaster runtime root, then starts:

```sh
./crimson.aarch64 \
  --runtime-dir ./runtime \
  --assets-dir ./assets \
  --width "$DISPLAY_WIDTH" \
  --height "$DISPLAY_HEIGHT" \
  --fullscreen
```

Runtime files, saves, configs, and logs are written under `crimson/runtime/`.
The launcher enables PortMaster controller defaults with
`CRIMSON_PORTMASTER_CONTROLS=1` and hides the custom UI cursor with
`CRIMSON_HIDE_UI_CURSOR=1`.

## Release Checklist

- Zip root contains `crimson.sh`.
- Zip root contains `crimson/`.
- `crimson/port.json` is present and advertises `aarch64`.
- `crimson/README.md`, `gameinfo.xml`, and `THIRD_PARTY_NOTICES.md` are present.
- `crimson/crimson.aarch64` is present and executable.
- `crimson/libs.aarch64/libraylib.so` is present and executable.
- `crimson/assets/` is empty in public release zips.
- The launcher passes `bash -n`.
- Device log shows raylib SDL initialization and all runtime textures loaded.
- Menu, quest selection, gameplay, pause, score screens, statistics, and
  high-score name entry are reachable with the gamepad.

## Resolution Testing

This PortMaster build is currently tested on 640x480. Other screen sizes may
work, but layout testing is still pending.

Before claiming broad resolution support, test:

- 640x480
- 720x720
- 800x480
- 854x480
- 960x544
- 1280x720

Capture screenshots for menus, quest selection, gameplay, results, statistics,
and high-score entry. If multiple non-4:3 devices show layout issues, add a
fixed 4:3 PortMaster viewport and render with letterbox or pillarbox bars
instead of adding per-device layout patches.

## Attribution and Redistribution

Crimsonland is the original game by 10tons Ltd. This package is an independent
community PortMaster build of the native Zig reimplementation from the Crimson
rewrite project. It is not an official 10tons release.

Do not include Crimsonland data archives in public PortMaster release zips
unless explicit redistribution permission is confirmed. This includes demo
archives; public packages should ship with an empty `crimson/assets/` directory
and let users provide their own game data.

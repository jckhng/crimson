---
tags:
  - contributor
  - portmaster
  - handheld
---

# PortMaster packaging (RG35XXH / muOS)

This package path targets the native Zig window executable instead of the old
Python/raylib/Nuitka bundle.

## Current finding

The native Zig window build works on the host:

```bash
cd crimson-zig
zig build window -Doptimize=ReleaseFast
```

Direct ARM64 cross-compile works for RG35XXH / muOS with raylib's SDL2 backend,
GLES2, dynamic raylib linkage, and JPEG texture support:

```bash
cd crimson-zig
PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig \
C_INCLUDE_PATH=/usr/include:/usr/include/aarch64-linux-gnu:/usr/include/SDL2 \
zig build --prefix zig-out-aarch64 window \
  -Dtarget=aarch64-linux-gnu.2.36 \
  -Dplatform=sdl2 \
  -Dopengl_version=gles_2 \
  -Dlinkage=dynamic \
  -Doptimize=ReleaseFast
```

The device does not expose `/dev/dri`, so raylib's DRM/KMS backend is not viable
there. SDL2 initializes the Mali GLES stack through the system SDL2 runtime.
Raylib must be built with `SUPPORT_FILEFORMAT_JPG=1` because Crimson's JAZ
textures contain embedded JPEG payloads.

## Docker build

The checked-in Dockerfile installs Zig 0.16.0 and the ARM64 SDL2 development
package:

```bash
docker build -f packaging/portmaster/zig-aarch64.Dockerfile -t crimson-zig-aarch64 .
docker run --rm -v "$PWD:/work" crimson-zig-aarch64
```

If successful, the ARM64 executable is:

```text
crimson-zig/zig-out-aarch64/bin/crimson-zig-window
```

The current cross-build uses dynamic raylib linkage. The executable needs the
generated ARM64 `libraylib.so` from the Zig cache. The RG35XXH / muOS image
provides `libSDL2-2.0.so.0`.

## Package

Stage the PortMaster zip with:

```bash
scripts/portmaster/build_zig_aarch64_bundle.sh \
  --binary crimson-zig/zig-out-aarch64/bin/crimson-zig-window \
  --assets-dir "$HOME/.local/share/banteg/crimsonland" \
  --out-dir artifacts/portmaster
```

The package script auto-detects the generated `libraylib.so` under
`crimson-zig/.zig-cache/o`. Pass `--lib-dir` only if you need to override that.
Use `--assets-dir` only for local device testing. Public release zips should not
include `crimson.paq`, `music.paq`, or `sfx.paq`; users must provide their own
archives.

Copy `artifacts/portmaster/Crimson-rg35xxh-zig-portmaster.zip` to the device.

## Runtime contract

`crimson.sh` launches:

```bash
./crimson.aarch64 \
  --runtime-dir ./crimson/runtime \
  --assets-dir ./crimson/assets \
  --width 640 \
  --height 480 \
  --fullscreen
```

Behavior:

- Writes runtime files to `crimson/runtime/`.
- Loads original archives from `crimson/assets/`.
- Uses PortMaster `runtime=blank`, `arch=aarch64`.
- Seeds new configs with PortMaster controls when `CRIMSON_PORTMASTER_CONTROLS=1`:
  left stick moves, right stick aims, and pushing the right stick fires.
- Hides Crimson's custom UI cursor when `CRIMSON_HIDE_UI_CURSOR=1`.
- Starts `gptokeyb` with `crimson.gptk` by default for keyboard/menu fallback
  controls. Gameplay aiming uses native raylib gamepad axes instead of mouse
  cursor emulation. Set `CRIMSON_USE_GPTOKEYB=0` to test native raylib gamepad
  input only.

## Validation checklist

- Binary is `ELF 64-bit ... ARM aarch64`.
- `ldd` resolves `libraylib.so` from `crimson/lib/` and `libSDL2-2.0.so.0`
  from the device image.
- Log shows `Platform backend: DESKTOP (SDL)`, `DISPLAY: Device initialized
  successfully`, and the last runtime texture (`ID 72`) loaded.
- Boots from PortMaster and returns cleanly to menu shell on exit.
- No writes outside `crimson/runtime/`.
- Input verifies movement, aim/fire/reload, menu confirm/cancel.
- New runtime config on PortMaster defaults to `Twin Stick Fire`; existing
  runtime configs must be reset or edited to pick up the new scheme.
- 10-minute Survival run without crash.
- Saves/config/replays persist across relaunch.

## 640x480 UX audit

Target device resolution is 640x480. Before publishing a PortMaster release,
walk the following screens on hardware and verify every panel, label, button,
and prompt is fully visible and reachable with gamepad controls:

- Boot and main menu.
- Play Game, Quests, Options, Controls, Statistics, Mods, Network, Other Games.
- Quest completed, quest failed, game over, high-score name entry, and high
  score tables.
- Pause menu and in-game HUD at 1-4 players.
- Typ'o'Shooter prompt/input surfaces.

Known handheld-specific rules:

- Avoid raw desktop anchors for panels wider than the device; clamp to
  `window_ui.fitRectToScreen` or a screen-aware layout helper.
- Keep B/Escape as an in-app cancel/back action, not raylib's process exit key.
- If a text-entry prompt cannot accept controller text input, B/Escape must
  leave the prompt without trapping the player.

## Release plan

1. Rebuild the ARM64 binary with the SDL2/GLES2 command above.
2. Stage a package with `scripts/portmaster/build_zig_aarch64_bundle.sh`.
3. Install the zip on RG35XXH / muOS and complete the validation checklist.
4. Replace `porter`, title, description, and metadata fields with final
   PortMaster submission values.
5. Capture a clean device log from first launch, gameplay launch, score save,
   and quit.
6. Submit the package with assets excluded; users must provide Crimsonland
   `.paq` files from their own installation. Do not include demo `.paq` files
   unless explicit redistribution permission is confirmed.

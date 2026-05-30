# Crimson PortMaster package scaffold

This template is staged by `scripts/portmaster/build_zig_aarch64_bundle.sh`.

Copy the original game archives into `crimson/assets/` before launching, or
pass `--assets-dir` to the package script:

- `crimson.paq`
- `music.paq`
- `sfx.paq`

Runtime files are written under `crimson/runtime/`.

New runtime configs default to left-stick movement and right-stick aim/fire.
Controls use `crimson.gptk` by default for keyboard/menu fallbacks, but
gameplay aiming uses native raylib gamepad axes instead of mouse cursor
emulation. Set `CRIMSON_USE_GPTOKEYB=0` before launching to test native raylib
gamepad input only.

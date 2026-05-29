# Crimson PortMaster package scaffold

This template is staged by `scripts/portmaster/build_zig_aarch64_bundle.sh`.

Copy the original game archives into `crimson/assets/` before launching, or
pass `--assets-dir` to the package script:

- `crimson.paq`
- `music.paq`
- `sfx.paq`

Runtime files are written under `crimson/runtime/`.

Controls use `crimson.gptk` by default for menu/gameplay keyboard and mouse
fallbacks. Set `CRIMSON_USE_GPTOKEYB=0` before launching to test native
raylib gamepad input only.

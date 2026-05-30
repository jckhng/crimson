# Crimson PortMaster package scaffold

This template is staged by `scripts/portmaster/build_zig_aarch64_bundle.sh`.

Copy the original game archives into `crimson/assets/` before launching. For
local testing only, pass `--assets-dir` to the package script:

- `crimson.paq`
- `music.paq`
- `sfx.paq`

Runtime files are written under `crimson/runtime/`.

Do not include Crimsonland data archives in public PortMaster release zips
unless you have explicit redistribution permission. This includes demo archives;
public packages should ship with an empty `crimson/assets/` directory and let
users provide their own `.paq` files.

New runtime configs default to left-stick movement and right-stick aim/fire.
Controls use `crimson.gptk` by default for keyboard/menu fallbacks, but
gameplay aiming uses native raylib gamepad axes instead of mouse cursor
emulation. The PortMaster launcher hides Crimson's custom UI cursor for
controller-only navigation. Set `CRIMSON_USE_GPTOKEYB=0` before launching to
test native raylib gamepad input only.

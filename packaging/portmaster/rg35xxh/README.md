# Crimsonland PortMaster package scaffold

This template is staged by `scripts/portmaster/build_zig_aarch64_bundle.sh`.
It is intended for the downstream PortMaster branch/fork, not as a
parity-preserving upstream package.

Copy the original game archives into `crimson/assets/` before launching. The
native PortMaster build can run without music; `music.paq` is optional. GOG
installs that ship loose OGG music can use `crimson/assets/music/*.ogg` instead
of `music.paq`. For local testing only, pass `--assets-dir` to the package
script:

- `crimson.paq`
- `sfx.paq`
- `music.paq` or `music/*.ogg` (optional)

Runtime files are written under `crimson/runtime/`.

## Attribution and redistribution

Crimsonland is the original game by 10tons Ltd. This package is an independent
community PortMaster build of the native Zig reimplementation from the Crimson
rewrite project. It is not an official 10tons release.

Do not include Crimsonland data archives in public PortMaster release zips
unless you have explicit redistribution permission. This includes demo archives;
public packages should ship with an empty `crimson/assets/` directory and let
users provide their own `.paq` files.

The upstream Crimson rewrite README says the original Crimsonland Classic assets
are distributed for that project with permission from the original developer.
That permission should not be assumed to cover third-party PortMaster release
zips unless the release owner has verified it.

New runtime configs default to left-stick movement and right-stick aim/fire.
Controls use `crimson.gptk` by default for keyboard/menu fallbacks, but
gameplay aiming uses native raylib gamepad axes instead of mouse cursor
emulation. Y opens perk picking, L1/L2 reload, and X sends Backspace for
high-score name entry. The PortMaster launcher hides Crimson's custom UI cursor
for controller-only navigation. Set `CRIMSON_USE_GPTOKEYB=0` before launching
to test native raylib gamepad input only.

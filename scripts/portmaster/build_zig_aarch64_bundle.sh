#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  scripts/portmaster/build_zig_aarch64_bundle.sh --binary /path/to/crimson-zig-window [--lib-dir /path/to/libs] [--assets-dir /path/to/assets] [--out-dir artifacts/portmaster]

Description:
  Stages a PortMaster package from packaging/portmaster/rg35xxh and emits a zip.
  The binary should be an aarch64 Linux crimson-zig-window build.
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/packaging/portmaster/rg35xxh"
OUT_DIR="$ROOT_DIR/artifacts/portmaster"
BIN_PATH=""
LIB_DIR=""
ASSETS_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --binary)
            BIN_PATH="$2"
            shift 2
            ;;
        --lib-dir)
            LIB_DIR="$2"
            shift 2
            ;;
        --assets-dir)
            ASSETS_DIR="$2"
            shift 2
            ;;
        --out-dir)
            OUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage
            exit 1
            ;;
    esac
done

if [[ -z "$BIN_PATH" ]]; then
    echo "--binary is required" >&2
    usage
    exit 1
fi
if [[ ! -f "$BIN_PATH" ]]; then
    echo "Binary not found: $BIN_PATH" >&2
    exit 1
fi

case "$(file -b "$BIN_PATH")" in
    *"ARM aarch64"*) ;;
    *)
        echo "Expected an aarch64 binary, got: $(file -b "$BIN_PATH")" >&2
        exit 1
        ;;
esac

if [[ -z "$LIB_DIR" ]]; then
    RUNPATH="$(readelf -d "$BIN_PATH" 2>/dev/null | sed -n 's/.*Library runpath: \[\(.*\)\].*/\1/p' | tr ':' '\n' | head -n 1 || true)"
    if [[ -n "$RUNPATH" && -f "$ROOT_DIR/crimson-zig/$RUNPATH/libraylib.so" ]]; then
        LIB_DIR="$(cd "$ROOT_DIR/crimson-zig/$RUNPATH" && pwd)"
    fi
fi

if [[ -z "$LIB_DIR" ]]; then
    RAYLIB_PATH="$(find "$ROOT_DIR/crimson-zig/.zig-cache/o" -path '*/libraylib.so' -type f -print 2>/dev/null | sort | head -n 1 || true)"
    if [[ -n "$RAYLIB_PATH" ]]; then
        LIB_DIR="$(cd "$(dirname "$RAYLIB_PATH")" && pwd)"
    fi
fi

STAGE_DIR="$OUT_DIR/Crimson"
rm -rf "$STAGE_DIR"
mkdir -p "$OUT_DIR"
cp -a "$TEMPLATE_DIR" "$STAGE_DIR"

rm -rf "$STAGE_DIR/crimson/bin"
cp -a "$BIN_PATH" "$STAGE_DIR/crimson/crimson.aarch64"
chmod +x "$STAGE_DIR/crimson.sh" "$STAGE_DIR/crimson/crimson.aarch64"

if [[ -n "$LIB_DIR" ]]; then
    if [[ ! -d "$LIB_DIR" ]]; then
        echo "Library directory not found: $LIB_DIR" >&2
        exit 1
    fi
    find "$LIB_DIR" -maxdepth 1 \( -type f -o -type l \) -name '*.so*' -exec cp -a {} "$STAGE_DIR/crimson/lib/" \;
fi

if [[ -n "$ASSETS_DIR" ]]; then
    if [[ ! -d "$ASSETS_DIR" ]]; then
        echo "Asset directory not found: $ASSETS_DIR" >&2
        exit 1
    fi
    for archive in crimson.paq music.paq sfx.paq; do
        if [[ ! -f "$ASSETS_DIR/$archive" ]]; then
            echo "Missing required archive: $ASSETS_DIR/$archive" >&2
            exit 1
        fi
        cp -a "$ASSETS_DIR/$archive" "$STAGE_DIR/crimson/assets/"
    done
fi

(
    cd "$STAGE_DIR"
    ZIP_PATH="$OUT_DIR/Crimson-rg35xxh-zig-portmaster.zip"
    rm -f "$ZIP_PATH"
    if command -v zip >/dev/null 2>&1; then
        zip -r "$ZIP_PATH" crimson.sh crimson >/dev/null
    elif command -v bsdtar >/dev/null 2>&1; then
        bsdtar -a -cf "$ZIP_PATH" crimson.sh crimson
    else
        echo "Need zip or bsdtar to create PortMaster archive" >&2
        exit 1
    fi
)

echo "Built: $OUT_DIR/Crimson-rg35xxh-zig-portmaster.zip"

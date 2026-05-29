#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/crimson/
RUNTIME_DIR="$GAMEDIR/runtime"
ASSETS_DIR="$GAMEDIR/assets"
BIN_NAME="crimson.${DEVICE_ARCH}"
BIN_PATH="$GAMEDIR/$BIN_NAME"
GPTK_PATH="$GAMEDIR/crimson.gptk"

mkdir -p "$RUNTIME_DIR" "$RUNTIME_DIR/home" "$ASSETS_DIR"
cd "$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export CRIMSON_RUNTIME_DIR="$RUNTIME_DIR"
export CRIMSON_ASSETS_DIR="$ASSETS_DIR"
export HOME="$RUNTIME_DIR/home"
export XDG_DATA_HOME="$RUNTIME_DIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$GAMEDIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

if [[ ! -x "$BIN_PATH" ]]; then
    echo "Missing executable: $BIN_PATH" >&2
    exit 1
fi

if [[ "${CRIMSON_USE_GPTOKEYB:-1}" != "0" && -n "${GPTOKEYB:-}" && -f "$GPTK_PATH" ]]; then
    $GPTOKEYB "$BIN_NAME" -c "$GPTK_PATH" &
fi

pm_platform_helper "$BIN_PATH"

"$BIN_PATH" \
    --runtime-dir "$RUNTIME_DIR" \
    --assets-dir "$ASSETS_DIR" \
    --width 640 \
    --height 480 \
    --fullscreen

pm_finish

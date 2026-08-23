#!/bin/sh

# -e stops the script if compilation fails.
# -u reports undefined variables.
# -x display each shell command before it is executed.
set -eux


SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_NAME=$(basename -- "$0")

find "$SCRIPT_DIR" \
    -maxdepth 1 \
    -type f \
    ! -name "1-compile.sh" \
    ! -name "2-simulate.sh" \
    ! -name "3-debug.sh" \
    ! -name "$SCRIPT_NAME" \
    -print \
    -delete
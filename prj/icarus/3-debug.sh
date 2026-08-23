#!/bin/sh

# -e stops the script if compilation fails.
# -u reports undefined variables.
# -x display each shell command before it is executed.
set -eux

SOURCE_FILES="waveform.vcd"

gtkwave $SOURCE_FILES

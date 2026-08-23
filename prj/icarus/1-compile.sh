#!/bin/sh

# -e stops the script if compilation fails.
# -u reports undefined variables.
# -x display each shell command before it is executed.
set -eux

#SOURCE_FILES="
#../vlog/rsa_core_ctrl.v
#../vlog/rsa_core_mod.v
#../vlog/rsa_core_mult.v
#../vlog/rsa_core.v
#../vlog/rsa_core_tb.v
#"

SOURCE_FILES="
../vlog/rsa_core.v
../vlog/rsa_core_tb.v
"

OUTPUT_FILE="simulation_code.vvp"

iverilog            \
    -Wall           \
    -g2012          \
    -s rsa_core_tb  \
    -o $OUTPUT_FILE \
    $SOURCE_FILES

chmod 644 $OUTPUT_FILE

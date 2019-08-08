#!/bin/bash

CRASHINGBIN=/usr/bin/clr-telemetry-bbt.out
CRASHINGDEBUGBIN=/usr/bin/clr-telemetry-bbt-debug.out

# Report sample crashlog
#
function report_crash() {
     local e="crash"
     local E="${CRASHINGBIN}"
     local s=6
     # using cat insted of -c swicth from crashprobe to 1- emulate the kernel
     # piping data, and 2- get around the need of an absulute path for options
     cat $SRC/corefile-sample | /usr/bin/crashprobe -p "${e}" -E "${E}" -s ${s}
}

# Install binary
#
function install_binary() {
    local binary_file=$1
    local binary_dest=$2
    cp $SRC/${binary_file} ${binary_dest}
    chmod uo+x ${binary_dest}
}

# Install crashing binary
#
function install_crashing_binary() {
    install_binary "crash.out" ${CRASHINGBIN}
}

# Install crashing with info
# binary
function install_crashing_with_info_binary() {
    install_binary "crash-debug-info.out" ${CRASHINGDEBUGBIN}
}


# Get line number were the last occurence
# of line_index in backtrace was found in
# journal
function get_line_index() {
    local backtrace=${1}
    local journal=${2}
    local line_index=${3}
    n=$(grep -nr -Eo "$(head -n ${line_index} ${backtrace} | tail -n 1)" ${journal} | tail -n 1 | cut -d':' -f1)
    echo ${n:-'0'}
}

# Check backtrace in journal against expected
# backtrace
# 0 error, 1 matches
function check_backtrace() {
    local since="${1}"
    local backtrace=${SRC}/backtrace.txt
    local last_line=$(tail -n 1 ${backtrace})
    local N=$(wc -l ${backtrace} | cut -d' ' -f1)
    # Block until last line shows up or timeouts
    local sync=$(sync_received_count "${last_line}" "${since}" "-Eo")
    if [ "$sync" -eq 0 ]; then
        echo 0
        return
    fi
    # Copy journal to temp file
    local tmp_backtrace=$(mktemp /tmp/backtrace-XXXXX)
    journalctl --since "${since}" -o cat -u mock-telemetrics.service >> $tmp_backtrace
    local start=$(get_line_index ${backtrace} ${tmp_backtrace} 1)
    if [ "$start" -eq 0 ];then
        echo 0
        return
    fi
    # Loop on backtrace.txt lines
    for i in `seq 2 ${N}`; do
        # Get index for tmp_backtrace line that matches backtrace i line
        next=$(get_line_index ${backtrace} ${tmp_backtrace} ${i})
        if [ $(expr $next - $start) -ne 1 ]; then
            echo "ERROR in ${FUNCNAME[0]} matching line ${i}"
            tail -n 20 ${tmp_backtrace}
            return
        fi
        start=$next
    done
    rm -f $tmp_backtrace
    echo 1
}

#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# crashprobe tests
# -----------------
#
# Author      :   Alex Jaramillo
#
# Requirements:   bundle telemetrics
#

SRC="../../src/telemetrics"
load $SRC/common
load $SRC/crash

setup() {
     telemetry_common_setup
}

teardown() {
     telemetry_common_teardown
}

@test "kernel reporting to crashprobe" {
     since=$(date +"%Y-%m-%d %T")
     install_crashing_binary
     BEFORE=$(sync_received_count "org.clearlinux/crash/error" "${since}")
     run ${CRASHINGBIN}
     [ "$status" -eq 139 ]
     AFTER=$(sync_received_count "org.clearlinux/crash/error" "${since}")
     echo "after: $AFTER, before: $BEFORE"
     [ "$AFTER" -gt "$BEFORE" ]
     rm ${CRASHINGBIN}
     # Make sure the backtrace check was
     # attempted, though will fail due to
     # missing debug info
     HAS_BACKTRACE=$(sync_received_count "Error: Failed to find module for current frame" "${since}")
     [ "$HAS_BACKTRACE" -gt 0 ]
}

@test "check for backtrace in crashprobe report" {
     since=$(date +"%Y-%m-%d %T")
     install_crashing_with_info_binary
     # Run in background so crash does not
     # stop test. Not running with -run- cmd
     # so real trace is visible
     ${CRASHINGDEBUGBIN} &
     MATCHES=$(check_backtrace "${since}")
     echo "$MATCHES"
     [ "$MATCHES" -eq 1 ]
     rm ${CRASHINGDEBUGBIN}
}

@test "crashprobe core pattern" {
     core_pattern=$(cat /proc/sys/kernel/core_pattern)
     [ "$core_pattern" = "|/usr/lib/systemd/coredump-wrapper %E %P %u %g %s %t %c %h %e" ]
}

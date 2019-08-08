#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# hprobe test
# -----------------
#
# Author      :   Alex Jaramillo
#
# Requirements:   bundle telemetrics
#

HPROBEBIN=/usr/bin/hprobe
SRC="../../src/telemetrics"
load $SRC/common

setup() {
     telemetry_common_setup
}

teardown() {
     telemetry_common_teardown
}

@test "hprobe record verification" {
     BEFORE=$(received_count "hello$")
     run $HPROBEBIN
     [ "$status" -eq 0 ]
     AFTER=$(received_count "hello$")
     echo "After [$AFTER] should be gt Before [$BEFORE]"
     [ "$AFTER" -gt "$BEFORE" ]
}


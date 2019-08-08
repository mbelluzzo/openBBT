#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# opt-in, opt-out telemetry tests
# -----------------
#
# Author      :   Alex Jaramillo
#
# Requirements:   bundle telemetrics
#

HPROBEBIN=/usr/bin/hprobe
TELEMCTL=/usr/bin/telemctl
OPTOUTFILE=/etc/telemetrics/opt-out
SRC="../../src/telemetrics"
load $SRC/common

setup() {
     telemetry_common_setup
     $TELEMCTL stop
}

teardown() {
     telemetry_common_teardown
     rm -rf $OPTOUTFILE
}

@test "opt-in" {
     $TELEMCTL opt-out
     optout_state=$(ls $OPTOUTFILE | wc -l)
     [ "$optout_state" -eq 1 ]
     $TELEMCTL opt-in
     run $TELEMCTL start
     [ "$status" -eq 0 ]
     isactive=$($TELEMCTL is-active)
     [[ $isactive = $"telemprobd : active"* ]]
     [[ $isactive = *"telempostd : active" ]]
}

@test "opt-out" {
     $TELEMCTL opt-out
     run $TELEMCTL start
     [ "$status" -eq 1 ]
     isactive=$($TELEMCTL is-active)
     [[ $isactive = $"telemprobd : inactive"* ]]
     [[ $isactive = *"telempostd : inactive" ]]
}


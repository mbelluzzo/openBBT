#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# machine_id tests
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
     # Activate daemon
     run $HPROBEBIN
     [ "$status" -eq 0 ]
}

teardown() {
     telemetry_common_teardown
}

@test "Machine id change every 3 days" {
     # Read machine id
     initial_machine_id=$(cat_machine_id)
     rewind_file_time $MACHINEID '-4 days'
     telemetry_restart_without_probes
     run $HPROBEBIN
     [ "$status" -eq 0 ]
     new_machine_id=$(cat_machine_id)
     echo "$initial_m_id $new_m_id"
     [ "$initial_machine_id" != "$new_machine_id" ]
}

@test "Static machine id" {
     initial_machine_id=$(cat_machine_id)
     run $HPROBEBIN
     [ "$status" -eq 0 ]
     IDCOUNT=$(received_count $initial_machine_id)
     [ "$IDCOUNT" -ge 1 ]
     telemetry_restart_without_probes
     machine_id=$(set_static_machine_id)
     run $HPROBEBIN
     [ "$status" -eq 0 ]
     IDCOUNT=$(received_count $machine_id)
     [ "$IDCOUNT" -eq 1 ]
}

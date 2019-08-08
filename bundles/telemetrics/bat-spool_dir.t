#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# spool directory tests
# -----------------
#
# Author      :   Alex Jaramillo
#
# Requirements:   bundle telemetrics
#

CLASS="bat/sdl/spool_size_limit"
SRC="../../src/telemetrics"
load $SRC/common
load $SRC/rate_limit


setup() {
     clean_telemetry_spool
     telemetry_common_setup
}

teardown() {
     telemetry_common_teardown
     clean_telemetry_spool
}

@test "Spool dir size restriction" {
     # Set low spool dir size to hit
     # limits with medium size payload
     set_low_spool_dir_limit
     send_n_records 5 "hello"
     LIMITED=$(stable_spooled_count 1)
     echo "LIMITED should be 1, its $LIMITED instead"
     [ "$LIMITED" -eq 1 ]
}

@test "Spool dir process time" {
     # Record limit = 2 and low
     # process time
     update_telemd_record_burst_limit
     set_low_spool_process_time
     send_n_records 5 "Hello"
     # Force restart timer
     sleep 140
     SPOOLED=$(stable_spooled_count 0)
     echo "SPOOLED should be 0, its $SPOOLED instead"
     [ "$SPOOLED" -eq 0 ]
     # Record limit = 2 and default
     # process time
     update_telemd_conf
     update_telemd_record_burst_limit
     send_n_records 5 "$PAYLOAD"
     sleep 140
     SPOOLED=$(stable_spooled_count 3)
     [ "$SPOOLED" -eq 3 ]
}

@test "Drop records do not spool" {
     # Set record limit = 2 to hit
     # spooling
     update_telemd_record_burst_limit
     set_rate_limit_strategy "drop"
     send_n_records 5 "PAYLOAD"
     SPOOLED=$(stable_spooled_count 0)
     [ "$SPOOLED" -eq 0 ]
     set_rate_limit_strategy "spool"
     send_n_records 5 "PAYLOAD"
     SPOOLED=$(stable_spooled_count 3)
     [ "$SPOOLED" -eq 3 ]
}

@test "Spooled record expiration" {
     # Set record limit = 2 to hit
     # spooling
     update_telemd_record_burst_limit
     PAYLOAD=$(head -c 52 /dev/urandom | base64)
     # Spool 3 records and modify time
     # for spooled records
     send_n_records 5 "$PAYLOAD"
     SPOOLED=$(stable_spooled_count 3)
     [ "$SPOOLED" -eq 3 ]
     telemctl stop
     for i in $(ls "$TELEMDSPOOL"); do
         rewind_file_time ${TELEMDSPOOL}/$i '-1 days'
     done
     # Set expiration to 1 minute and
     # disable limiting
     set_low_record_expiration
     update_telemd_conf
     disable_telemd_rate_limit
     SPOOLED=$(stable_spooled_count 0)
     # Check that spool dir is empty and
     # no records were sent to backend
     echo "Spool should be emty its $SPOOLED instead"
     [ "$SPOOLED" -eq 0 ]
     PAYLOAD_COUNT=$(received_count "$PAYLOAD")
     # Payload count should be 2 from the previously
     # sent recods
     [ "$PAYLOAD_COUNT" -eq 2 ]
}

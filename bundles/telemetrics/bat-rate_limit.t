#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# rate limiting tests
# -----------------
#
# Author      :   Alex Jaramillo
#
# Requirements:   bundle telemetrics
#

CLASS="bat/sdl/rate_limit_enabled"
SRC="../../src/telemetrics"
load $SRC/common
load $SRC/rate_limit


setup() {
     telemetry_common_setup
}

teardown() {
     telemetry_common_teardown
     clean_telemetry_spool
}

@test "Enabled rate limits" {
     # Base line when disabled should be
     # no record spooled
     disable_telemd_rate_limit
     PAYLOAD=$(get_payload 1)
     send_n_records 10 $PAYLOAD
     BASELINE=$(stable_spooled_count 0)
     [ "$BASELINE" -eq 0 ]
     # After enabling rate limits there
     # should be spooled records
     enable_telemd_rate_limit
     send_n_records 10 $PAYLOAD
     LIMITED=$(stable_spooled_count 0)
     [ "$LIMITED" -gt 0 ]
}

@test "Byte burst limit with disabled record limit" {
     # Increase byte limit allows multiple
     # small messages to be reported
     increase_byte_burst_limit
     PAYLOAD=$(echo $(get_payload 1) | cut -c1-8)
     send_n_records 8 $PAYLOAD
     LATEST_COUNT=$(stable_spooled_count 0)
     echo "Spooled count should be 0, its $LATEST_COUNT"
     [ "$LATEST_COUNT" -eq 0 ]
     # Decrease byte limit and bump payload size
     # to trigger rate limiting and spooling
     decrease_byte_burst_limit
     PAYLOAD=$(get_payload 10)
     send_n_records 10 $PAYLOAD
     SPOOLED=$(stable_spooled_count 0)
     [ "$SPOOLED" -gt 0 ]
}

@test "Record burst limit with disabled byte limit" {
    # Set record limit to 2 and count the
    # number of records spooled
    update_telemd_record_burst_limit
    PAYLOAD=$(get_payload 20)
    send_n_records 8 $PAYLOAD
    LATEST_COUNT=$(stable_spooled_count 6)
    [ "$LATEST_COUNT" -eq 6 ]
}

# Both enabled, byte should hit first
@test "Byte burst limit with enabled record limit" {
    # Update conf to a high record rate
    # and low byte rate to force triggering
    # byte rate limits
    update_telemd_byte_over_record
    PAYLOAD=$(get_payload 10)
    send_n_records 8 $PAYLOAD
    SPOOLED=$(stable_spooled_count 1)
    echo "Spool is $SPOOLED should be > 1"
    [ "$SPOOLED" -gt 1 ]
}

# Both enabled, record count should hit first
@test "Record burst limit with enabled byte limit" {
    # Update conf to a high byte rate and
    # low record rate to force triggering
    # record limits
    update_telemd_record_over_byte
    PAYLOAD=$(get_payload 10)
    send_n_records 5 $PAYLOAD
    SPOOLED=$(stable_spooled_count 3)
    echo "Spool is $SPOOLED should be = 3"
    [ "$SPOOLED" -eq 3 ]
}

#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# telemetry journal test
# -----------------
#
# Author      :   Alex Jaramillo
#
# Requirements:   bundle telemetrics
#

HPROBEBIN=/usr/bin/hprobe
TELEM_JOURNAL_FILE=/var/log/telemetry/journal
SRC="../../src/telemetrics"
load $SRC/common
load $SRC/journal

setup() {
     telemetry_common_setup
     # Activate daemon
     run $HPROBEBIN
     [ "$status" -eq 0 ]
}

teardown() {
     telemetry_common_teardown
}

@test "check journal entry" {
     BEFORE=$(count_journal_entries)
     insert_n_entries 3
     AFTER=$(count_journal_entries)
     echo "After [$AFTER] should be gt Before [$BEFORE]"
     RESULT=$(expr $AFTER - $BEFORE)
     echo "Result should be 3 it's $RESULT instead"
     [ "$RESULT" == 3 ]
}

@test "single event_id entries" {
     local event_id=$(hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/urandom)
     # add several records 4 of them tagged with event_id
     # check that 4 of all records have given event_id
     insert_n_entries 2
     insert_n_entries 2 "${event_id,,}"
     insert_n_entries 1
     insert_n_entries 2 "${event_id,,}"
     RESULT=$(count_journal_entries ${event_id,,})
     echo "Result should be 4 its $RESULT instead"
     [ "$RESULT" == "4" ]
}

#!/usr/bin/env bats

# journalprobe tests
# -----------------
#
# Author      :   California Sullivan
#
# Requirements:   bundle telemetrics
#

SRC="../../src/telemetrics"
load $SRC/common

setup() {
    telemetry_common_setup
    cp ${TELEMSRC}/mock-failing-service.service /usr/lib/systemd/system/
    systemctl daemon-reload
    journalctl --rotate
}

teardown() {
    telemetry_common_teardown
    rm /usr/lib/systemd/system/mock-failing-service.service
    systemctl daemon-reload
}

# Wait until sync_received_count for the last second is zero
wait_journal_inactive () {
    # Ensure that we are not still receiving old mock-failing-service messages
    for i in `seq 1 3`; do
        local since=$(date +"%Y-%m-%d %T")
        if [ $(sync_received_count "mock-failing-service" "${since}") -eq 0 ]; then
            break;
        fi
        sleep 1
    done
}

# Have a service fail before probe is ran, make sure its logged by journal-probe
@test "journalprobe scan all entries" {
    run systemctl start mock-failing-service
    since=$(date +"%Y-%m-%d %T")
    systemctl start journal-probe
    COUNT=$(sync_received_count "mock-failing-service" "${since}")
    telemctl stop
    echo "COUNT [$COUNT] should be greater than 0"
    [ "$COUNT" -gt 0 ]
}

# Have a service fail while probe is running, make sure its logged by journal-probe
@test "journalprobe scan while running" {
    # Let journal from previous test settle. Without the delay both
    # tests may occur within the same second, causing false failures
    wait_journal_inactive
    since=$(date +"%Y-%m-%d %T")
    systemctl start journal-probe
    run systemctl start mock-failing-service
    COUNT=$(sync_received_count "mock-failing-service" "${since}")
    telemctl stop
    echo "COUNT [$COUNT] should be greater than 0"
    [ "$COUNT" -gt 0 ]
}

# Have a service fail before probe is ran, make sure its not logged by journal-probe-tail
@test "journalprobe tail only scan new entries" {
    wait_journal_inactive
    since=$(date +"%Y-%m-%d %T")
    run systemctl start mock-failing-service
    systemctl start journal-probe-tail
    COUNT=$(sync_received_count "mock-failing-service" "${since}")
    telemctl stop
    echo "COUNT [$COUNT] should be equal to 0"
    [ "$COUNT" -eq 0 ]
}

# Have a service fail while probe is running, make sure its logged by journal-probe-tail
@test "journalprobe tail scan while running" {
    systemctl start journal-probe-tail
    wait_journal_inactive
    since=$(date +"%Y-%m-%d %T")
    run systemctl start mock-failing-service
    COUNT=$(sync_received_count "mock-failing-service" "${since}")
    telemctl stop
    echo "COUNT [$COUNT] should be greater than 0"
    [ "$COUNT" -gt 0 ]
}

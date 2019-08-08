#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

setup() {
        iperf3 -s &
        sleep 1
}

teardown() {
        pkill iperf3
        sleep 1
}

@test "iperf client tcp check" {
        iperf3 -c localhost
}

@test "iperf client udp check" {
        iperf3 -c localhost -u
}

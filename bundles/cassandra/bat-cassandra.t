#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

# cassandra - test
# --------------
#
# Author      :   Jue Wang
#
# Requirements:   bundle cassandra
#
#
#

BIN_FLINK="/usr/share/cassandra/bin"

setup() {
    export PATH=$BIN_FLINK:$PATH
    systemctl start cassandra &
    sleep 25
}

teardown() {
    systemctl stop cassandra
}

@test "test to connect cassandra server" {
    cqlsh --execute "SHOW VERSION"
}


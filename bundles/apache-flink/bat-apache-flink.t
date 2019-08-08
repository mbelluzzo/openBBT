#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*


# apache-flink - test
# --------------
#
# Author      :   Hongzhan Chen
#
# Requirements:   bundle apache-flink
#
#
#

BIN_FLINK="/usr/share/flink/bin"
LOG_FLINK="/var/log/flink"

setup() {
    mkdir -p $LOG_FLINK
    export FLINK_LOG_DIR=$LOG_FLINK
    export PATH=$BIN_FLINK:$PATH 
}

@test "cluster test" {
    start-cluster.sh
    flink list 
    curl --silent -X GET --noproxy 'localhost' 'http://localhost:8081/' \
       | grep "Apache Flink Web Dashboard"
    stop-cluster.sh
}

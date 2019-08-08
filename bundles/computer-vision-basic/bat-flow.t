#!/usr/bin/env bats
# *-*- Mode: sh -*-*

# darkflow - check darkflow (flow) and output
# -------------------
#
# Author      : Se Hun Kim
#
# Requirements: bundle darkflow computer-vision-basic
#

setup() {
    export ORIGINAL_PWD=$PWD
    export TEST_TMP=$(mktemp -d)
    mkdir ${TEST_TMP}/test-workdir
    cd ${TEST_TMP}/test-workdir
}

teardown() {
    cd ${ORIGINAL_PWD}
    rm -r ${TEST_TMP}/test-workdir
    rmdir ${TEST_TMP}
}

@test "flow" {
    git clone https://github.com/gogazago/darkflow_example.git
    cd darkflow_example
    flow --imgdir sample_img/ --model cfg/tiny-yolo-voc.cfg --load bin/tiny-yolo-voc.weights
    if [ ! -d sample_img/out ]; then
        echo "Error: darkflow doesn't work, output folder doesn't exist"
        return 1
    fi
}

#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# TCL Programming - basic test
# -----------------
#
# Author      :   Josue David Hernandez Gutierrez
#
# Requirements:   bundle tcl-basic
#

SRC_BASE="../../src/bat-tcl-basic"

setup() {
    pushd $SRC_BASE
}

#
# * Testing Expect
#
@test "Baisc expect test" {
    ./sample.expect
    cat hello | grep "hello world"
    rm hello
}

#
# * Basic TCL test
#
@test "Basic TCL test" {
    cd tcl_sample_code
    for i in $(ls .); do
        tclsh $i
    done
}

teardown() {
    popd
}

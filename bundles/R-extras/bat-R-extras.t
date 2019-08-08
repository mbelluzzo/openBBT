#!/usr/bin/env bats

# R - basic test
# --------------
#
# Author      :   Victor Rodriguez
#
# Requirements:   bundle R-extras

SRC="../../src/bat-R-extras/"

setup(){
    pushd ${SRC}
}

teardown(){
    popd
}

@test "R-bitops" {
    Rscript R-bitops.R
}

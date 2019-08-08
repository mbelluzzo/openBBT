#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Kernel rt - basic test
# -----------------
#
# Author      :   libertad
#
# Requirements:   bundle kernel-rt
#
SRC="../../src/kernel-params"

@test "Kernel rt parameters" {
    $SRC/kernel-params.sh
}

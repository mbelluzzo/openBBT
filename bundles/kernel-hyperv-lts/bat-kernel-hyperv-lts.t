#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Kernel hyperv-LTS - basic test
# -----------------
#
# Author      :   Carlos Arturo Garcia Garcia
#
# Requirements:   bundle kernel-hyperv-lts
#
SRC="../../src/kernel-params"

@test "Kernel hyperv-LTS parameters" {
    $SRC/kernel-params.sh
}

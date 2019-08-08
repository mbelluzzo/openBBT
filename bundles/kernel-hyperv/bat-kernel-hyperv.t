#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Kernel Hyperv - basic test
# -----------------
#
# Author      :   Josue David Hernandez Gutierrez
#
# Requirements:   bundle kernel-hyperv
#
SRC="../../src/kernel-params"

@test "Kernel hyperv parameters" {
    $SRC/kernel-params.sh
}

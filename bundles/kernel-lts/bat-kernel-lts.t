#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Kernel LTS - basic test
# -----------------
#
# Author      :   Josue David Hernandez Gutierrez
#
# Requirements:   bundle kernel-lts
#
SRC="../../src/kernel-params"

@test "Kernel LTS parameters" {
    $SRC/kernel-params.sh
}

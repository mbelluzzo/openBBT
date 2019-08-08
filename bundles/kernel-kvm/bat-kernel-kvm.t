#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Kernel KVM - basic test
# -----------------
#
# Author      :   Josue David Hernandez Gutierrez
#
# Requirements:   bundle kernel-kvm
#
SRC="../../src/kernel-params"

@test "Kernel KVM parameters" {
    $SRC/kernel-params.sh
}

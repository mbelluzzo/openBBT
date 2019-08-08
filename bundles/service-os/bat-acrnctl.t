#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# service-os - basic test
# -----------------
#
# Author      :   Libertad Gonzalez
#
# Requirements:   bundle kernel-pk service-os
#

@test "acrnctl list vm2" {
    acrnctl list | grep vm2
}

@test "acrnctl stop vm2" {
    acrnctl stop vm2
}

@test "acrnctl pause vm2" {
    acrnctl pause vm2
}

@test "acrnctl continue vm2" {
    acrnctl continue vm2
}

@test "acrnctl suspend vm2" {
    acrnctl suspend vm2
}

@test "acrnctl resume vm2" {
    acrnctl resume vm2
}

@test "acrnctl reset vm2" {
    acrnctl reset vm2
}

@test "acrnctl delete vm2" {
    acrnctl del vm2
}

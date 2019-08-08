#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Kernel pk - basic test
# -----------------
#
# Author      :   Libertad Gonzalez
#		  Carlos Arturo Garcia Garcia
# Requirements:   bundle kernel-iot-lts2018
#


SRC="../../src/kernel-params"

@test "Kernel IoT LTS 2018 parameters" {
    $SRC/kernel-params.sh
}

@test "mcelog help" {
   
    mcelog --help
}

@test "mcelog version" {
   
    mcelog --version
}

@test "irqbalance present" {
    ls /usr/bin/ | grep -q 'irqbalance'
}

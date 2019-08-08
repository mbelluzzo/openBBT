#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Kernel Native - basic test
# -----------------
#
# Author      :   Josue David Hernandez Gutierrez
#
# Requirements:   bundle kernel-native
#
SRC="../../src/kernel-params"

@test "Kernel Native parameters" {
    $SRC/kernel-params.sh
}

#
# For performance reasons, we dont want to load ip_tables and its friends in default boot
#
@test "No iptables by default" {
    Z=`lsmod | grep  ip_tables` || :
    [ -z "$Z" ]
}

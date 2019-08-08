#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# cloud-native-basic - files check
# -----------------
#
# Author      :   Marcos Simental
#
# Requirements:   bundle cloud-native-bundle


#
# * verify network utilities are present
#
@test "verify /usr/bin/ebtables is present" {
    [[ -f /usr/bin/ebtables ]]
}

@test "verify /usr/bin/ethtool is present" {
    [[ -f /usr/bin/ethtool ]]
}

@test "verify /usr/bin/socat is present" {
    [[ -f /usr/bin/socat ]]
}

#
# * verify k8s is present
#
@test "verify /usr/bin/kubeadm is present" {
    [[ -f /usr/bin/kubeadm ]]
}

@test "verify /usr/bin/kubectl is present" {
    [[ -f /usr/bin/kubectl ]]
}


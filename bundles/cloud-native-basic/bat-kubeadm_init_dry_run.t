#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Kubernetes - kubeadm init dry-run 
# -----------------
#
# Author      :   Jing Wang
#
# Requirements:   bundle cloud-native-bundle

K8S_CONFIG=/usr/share/clr-k8s-examples/kubeadm.yaml
setup() {
    modprobe br_netfilter
    swapoff -a
    sysctl -w net.ipv4.ip_forward=1
    systemctl start cri-o
    echo "127.0.0.1 localhost `hostname`" >> /etc/hosts
}

teardown() {
    sed -i '$ d' /etc/hosts
    systemctl stop cri-o
    swapon -a
    sysctl -w net.ipv4.ip_forward=0
}

#
# * verify k8s initialization
#
@test "dry run kubeadm init with cri-o" {
    kubeadm init --cri-socket=/run/crio/crio.sock --config ${K8S_CONFIG} --dry-run
    echo "y" | kubeadm reset --cri-socket=/run/crio/crio.sock
}

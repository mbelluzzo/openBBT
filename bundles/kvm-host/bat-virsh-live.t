#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# libvirt - basic test
# -----------------
#
# Author      :   Carlos Arturo Garcia Garcia
#
# Requirements:   kvm-host
#

SRC="../../src/bat-kvm-host"
setup() {
 network_name="default"
 vm_name="ClearLIVE-BBT"
}

@test "bat-virsh Star libvirtd " {
        systemctl restart libvirtd
}

@test "bat-virsh Create Network for VM" {
        pushd $SRC
        ./setup.sh live
        virsh net-create /var/taas/NetDef.xml
        popd
}

@test "bat-virsh Verify Network created" {
        virsh net-list | grep $network_name
}

@test "bat-virsh Create VM" {
        virsh create  /var/taas/ClearLIVE-BBT.xml
        sleep 20
}

@test "bat-virsh Verify VM created" {
        echo ""
        virsh list | grep $vm_name | grep running
}

@test "bat-virsh login using the console and set password" {
        pushd $SRC
        echo ""
        ./TestVM.expect $vm_name
        popd
        sleep 30
}

@test "bat-virsh login using the console and turn it off" {
        pushd $SRC
        echo ""
        ./TurnOffVM.expect $vm_name
        popd
        sleep 180
}

@test "bat-virsh Verify VM destroyed" {
        sleep 10
        ! virsh list | grep $vm_name | grep running
}

@test "bat-virsh Destroy Network" {
        virsh net-destroy $network_name
}

@test "bat-virsh stop libvirtd" {
        systemctl stop libvirtd
}

@test "bat-virsh create an image using qemu-img" {
        qemu-img create -f qcow2 /var/taas/foo.qcow2 100M
}

@test "bat-virsh validate image created" {
        [ -f /var/taas/foo.qcow2 ]
}

@test "bat-virsh cleanup" {
        rm -rf /var/taas
}

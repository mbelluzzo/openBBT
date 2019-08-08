#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Kernel pk - basic test
# -----------------
#
# Author      :   Libertad Gonzalez
#
# Requirements:   bundle kernel-pk
#

@test "mcelog help" {
	mcelog --help
}

@test "mcelog version" {
	mcelog --version
}

@test "irqbalance present" {
	ls /usr/bin/ | grep -q 'irqbalance'
}

@test "Kernel should list available USB devices - lsusb" {
	lsusb | grep -q 'Bus'
}

@test "PCI devices detected - VGA compatible controller" {
	lspci | grep -q 'VGA compatible controller'
}

@test "PCI devices detected - Communication controller" {
	lspci | grep -q 'Communication controller'
}

@test "PCI devices detected - Ethernet controller" {
	lspci | grep -q 'Ethernet controller'
}

@test "PCI devices detected - PCI bridge" {
	lspci | grep -q 'PCI bridge'
}

@test "Check kernel security config" {
	kcc /usr/lib/kernel/config-$(uname -r)
}

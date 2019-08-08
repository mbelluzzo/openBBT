#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Storage utils - disk encryption
# -----------------
#
# Author      :   Jair Gonzalez
#
# Requirements:   bundle storage-utils
#

src_path="../../src/disk-encryption"

load "$src_path"/disk-encryption

setup() {
	setup_temp_inodes
	setup_loop_device
	pushd "$src_path"
}

teardown() {
	popd
	unmount_unmap_detach_loop_device
	cleanup_temp_inodes
}

@test "cryptsetup simple partition encryption with LUKS" {
	cryptsetup_simple_partition_encryption_with_LUKS
}

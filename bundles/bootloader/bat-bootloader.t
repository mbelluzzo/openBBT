#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Bootloader tests
# -----------------
#
# Author      :   Jair Gonzalez
#
# Requirements:   bundle bootloader
#

SHIM_BOOT_SRC=/usr/lib/shim/shimx64.efi
SYSTEMD_BOOT_SRC=/usr/lib/systemd/boot/efi/systemd-bootx64.efi
ENTRY_PATTERN='.*Title: .*Linux.*
.*ID: 0x.+
.*Status: active, boot-order
.*Partition: /dev/disk/by-partuuid/.*
.*File: .*/EFI/org\.clearlinux/.*\.efi'
DEFAULT_ENTRY_PATTERN='Default Boot Loader Entry:
.*title: .*Linux.*
.*linux: /EFI/org\.clearlinux/kernel-org\.clearlinux.*
.*options: .*root=.*'

setup() {
    [[ ! -d /sys/firmware/efi ]] && skip "This system doesn't support UEFI"
    return 0
}

teardown() {
    systemctl stop boot.mount
}

@test "systemd-boot source exists" {
    [ -f "${SYSTEMD_BOOT_SRC}" ]
}

@test "shim loader source exists" {
    [ -f "${SHIM_BOOT_SRC}" ]
}

@test "clr-boot-manager help" {
    clr-boot-manager --help
}

@test "/boot is a FAT EFI partition" {
    systemctl start boot.mount
    mount | grep boot | grep -i "\<vfat\>"
}

@test "verify bootctl status" {
    systemctl start boot.mount
    result=$(bootctl status 2>&1)
    [[ $result =~ $ENTRY_PATTERN ]] || [[ $result =~ $DEFAULT_ENTRY_PATTERN ]]
}

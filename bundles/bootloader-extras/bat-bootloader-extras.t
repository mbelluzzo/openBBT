#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Bootloader-extras tests
# -----------------
#
# Author      :   Jair Gonzalez
#
# Requirements:   bundle bootloader-extras
#

BOOT_PART=/boot
INITRD_CPIO="${BOOT_PART}/EFI/org.clearlinux/freestanding-clr-init.cpio*"
DEFAULT_ENTRY_PATTERN='Default Boot Loader Entry:
.*linux: /EFI/org\.clearlinux/kernel-org\.clearlinux.*
.*initrd: .*/EFI/org\.clearlinux/freestanding-clr-init\.cpio.*
.*options: .*init=.*'

setup() {
    [[ ! -d /sys/firmware/efi ]] && skip "This system doesn't support UEFI"
    systemctl start boot.mount
}

teardown() {
    systemctl stop boot.mount
}

@test "initrd cpio exists" {
    compgen -G "${INITRD_CPIO}" > /dev/null
}

@test "verify bootctl status" {
    result=$(bootctl status 2>&1)
    [[ $result =~ $DEFAULT_ENTRY_PATTERN ]]
}

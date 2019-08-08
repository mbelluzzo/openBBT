#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Storage utils - basic test
# -----------------
#
# Author      :   Josue David Hernandez Gutierrez
#
# Requirements:   bundle storage-utils
#

@test "formating with mkfs.ext4" {
        td=$(mktemp -d)
        t=$(mktemp)
        dd if=/dev/zero of=$t bs=1k count=10000
        mkfs.ext4 -F $t 10000 && mount $t $td
        umount $td
        rm -rf $td $t
}

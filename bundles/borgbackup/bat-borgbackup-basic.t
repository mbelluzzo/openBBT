#!/usr/bin/env bats
# *-*- Mode: sh; sh-basic-offset: 8; indent-tabs-mode: nil -*-*

# borgbackup - basic test
# -----------------
#
# Author      :   Brett T. Warden
#
# Requirements:   bundle borgbackup
#

SRC=../../src/bat-borgbackup

setup() {
        pushd $SRC
        source borg_helper.bash
        dd if=/dev/urandom of=data/random bs=4096 count=1
}

teardown() {
        popd
}

#
# * Run borg command
#
@test "run borg command with no arguments" {
	borg
}

@test "run borg help" {
        # This runs the self-tests
	borg help
}

@test "back up and restore (no encryption, no compression)" {
        create_backup
        extract_and_check
}

@test "back up with zlib compression" {
        create_backup zlib
        extract_and_check
}

@test "back up with lz4 compression" {
        create_backup lz4
        extract_and_check
}

@test "back up with zstd compression" {
        create_backup zstd,19
        extract_and_check
}

@test "back up with lzma compression" {
        create_backup lzma
        extract_and_check
}

@test "AES + SHA256 repository" {
        export BORG_NEW_PASSPHRASE=foo
        export BORG_PASSPHRASE=foo
        create_backup none repokey
        extract_and_check

        BORG_PASSPHRASE=bar
        ! borg check repo
}

@test "AES + Blake2b repository" {
        export BORG_NEW_PASSPHRASE=foo
        export BORG_PASSPHRASE=foo
        create_backup none repokey-blake2
        extract_and_check

        BORG_PASSPHRASE=bar
        ! borg check repo
}

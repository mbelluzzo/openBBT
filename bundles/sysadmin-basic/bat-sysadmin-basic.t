#!/usr/bin/env bats
# *-*- Mode: sh; sh-basic-offset: 8; indent-tabs-mode: nil

@test "Man page for sync" {
       man 1 sync > /dev/null
}

@test "Man page for gzip" {
       man gzip  > /dev/null
}

@test "Man page for fsck.ext4" {
       man fsck.ext4  > /dev/null
}

@test "Man page for gawk" {
       man gawk  > /dev/null
}

@test "Man page for ps" {
       man ps  > /dev/null
}

@test "Man page for hostnamectl" {
       man hostnamectl  > /dev/null
}

@test "Man page for which" {
       man which  > /dev/null
}

@test "Man page for xz" {
       man xz  > /dev/null
}

@test "Man page for fdisk" {
       man fdisk  > /dev/null
}

@test "ps command health" {
       ps -waux  > /dev/null
}

@test "sudo command health" {
       sudo --help  > /dev/null
}

@test "Sudoers file does not exist in /usr/share/defaults/etc/" {
        [[ ! -f /usr/share/defaults/etc/sudoers ]]
}

@test "Sudoers file exists in /usr/share/defaults/sudo" {
        [[ -f /usr/share/defaults/sudo/sudoers ]]
}

@test "xz command health" {
       xz --help  > /dev/null
}


# test for JIRA CLEAR-2235
@test "bash login health" {
       run bash --login -c /usr/bin/true
       echo $output
       [ "$output" = "" ]
}

@test "aspell spell check" {
       echo "baad" > /tmp/aspell-bad
       echo "good" > /tmp/aspell-good
       local bad_ret=$(aspell list < "/tmp/aspell-bad")
       local good_ret=$(aspell list < "/tmp/aspell-good")

       [ -n "${bad_ret}" ]
       [ ! -n "${good_ret}" ]
}

#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

# koji - basic test
# -----------------
#
# Author      :   Jair Gonzalez
#
# Requirements:   koji
#

@test "koji help" {
    /usr/bin/koji help
    /usr/bin/koji --help
}

@test "kojid help" {
    /usr/bin/kojid --help
}

@test "kojira help" {
    /usr/bin/kojira --help
}

@test "koji services exist" {
    Services=(kojid.service kojira.service)
    for file in "${Services[@]}"; do
        [ -f /usr/lib/systemd/system/"${file}" ]
    done
}

@test "exportfs help" {
    exportfs -h
}

@test "nfs services exist" {
    Services=(nfs-server.service nfs-idmapd.service nfs-mountd.service \
              nfs-blkmap.service nfs-client.target)
    for file in "${Services[@]}"; do
        [ -f /usr/lib/systemd/system/"${file}" ]
    done
}

@test "postgres help-version" {
    /usr/bin/postgres --help
    /usr/bin/postgres --version
}

@test "postgres service exists" {
    [ -f /usr/lib/systemd/system/postgresql.service ]
}

@test "yum basic python deps" {
    yum -c /dev/null -help
}

@test "mash python2 modules exist" {
    python2 -c 'import mash'
}

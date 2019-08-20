#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

@test "ip command health" {
       ip -V  > /dev/null
}

@test "rsync command health" {
       rsync --help  > /dev/null
}

@test "curl command health" {
       curl --help  > /dev/null
}

@test "openssl command health" {
        openssl speed rsa512  > /dev/null
}

@test "bridge brctl test" {
       brctl --help > /dev/null
}

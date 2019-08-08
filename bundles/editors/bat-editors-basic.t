#!/usr/bin/env bats
# *-*- Mode: sh; sh-basic-offset: 8; indent-tabs-mode: nil



@test "joe command health" {
       joe --help  > /dev/null
}

@test "vim command health" {
       vim --help  > /dev/null
}

@test "emacs command health" {
       emacs --help  > /dev/null
}

@test "nano command health" {
       nano --help  > /dev/null
}

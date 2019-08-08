#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

@test "wget http check" {
	wget --quiet -O - http://google.com/ > /dev/null
}

@test "wget https check" {
	wget --quiet -O - https://download.clearlinux.org/latest > /dev/null
}

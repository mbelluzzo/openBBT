#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

@test "curl http check" {
	curl -s -f -o - http://google.com/ > /dev/null
}

@test "curl https check" {
	curl -s -f -o - https://download.clearlinux.org/latest > /dev/null
}

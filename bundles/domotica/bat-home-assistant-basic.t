#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# home-assistant - basic test
# -----------------
#
# Author      :   Brett T. Warden
#
# Requirements:   bundle domotica
#

#
# * Run hass command in foreground
#
@test "run hass, wait, then terminate it" {
	timeout --preserve-status -s INT -k 15 60 hass -v --skip-pip
}

#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

setup() {
        TMP_CACHE=$(mktemp)
}

teardown() {
        rm -f "${TMP_CACHE}"
}

@test "ldconfig returns no errors" {
	ldconfig -X -C "${TMP_CACHE}"
}

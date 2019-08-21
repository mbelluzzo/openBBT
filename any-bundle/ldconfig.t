#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

@test "ldconfig returns no errors" {
	LD_CACHE=$(mktemp)
	run ldconfig -C "$LD_CACHE"
	rm -f "$LD_CACHE"
}

@test "ldconfig has no weird libraries" {
	ldconfig -C -X
	count=`ldconfig -C -X 2>&1`
	[ "$count" == "" ]
}

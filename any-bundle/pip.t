#!/usr/bin/env bats

@test "pip3 check" {
	if type pip3; then
		pip3 check
	else
		skip "pip3 not present"
	fi
}

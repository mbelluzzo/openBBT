#!/usr/bin/env bats
# *-*- Mode: sh; sh-basic-offset: 8; indent-tabs-mode: nil -*-*

@test "phoronix-test-suite run" {
    phoronix-test-suite
}

@test "phoronix-test-suite system-info" {
    phoronix-test-suite system-info
}

@test "phoronix-test-suite install-run" {
    phoronix-test-suite batch-install pts/pybench
    phoronix-test-suite debug-run pts/pybench
}

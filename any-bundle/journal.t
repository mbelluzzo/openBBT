#!/usr/bin/env bats

@test "Journal does not contains: 'Cannot open pixbuf loader module file'" {
    ! journalctl -b | grep -c 'Cannot open pixbuf loader module file'
}

@test "Journal does not contains: 'libGL error: failed to load driver'" {
    ! journalctl -b | grep -c 'libGL error: failed to load driver'
}

@test "Journal does not contains: 'Direct firmware load for regulatory.db failed with error'" {
    ! journalctl -b | grep -c 'Direct firmware load for regulatory.db failed with error'
}

@test "Journal does not contains: 'invalid key/value pair in file'" {
    ! journalctl -b | grep -c 'invalid key/value pair in file'
}

@test "Journal does not contains: 'Process '/usr/bin/alsactl restore 1' failed with exit code 99.'" {
    ! journalctl -b | grep  '/usr/bin/alsactl' | grep -c 'failed with exit code'
}

@test "Failed to spawn Xwayland: Failed to execute child process" {
    ! journalctl -b | grep  'Failed to spawn Xwayland: Failed to execute child process' | grep -c '/usr/bin/haswell/Xwayland'
}

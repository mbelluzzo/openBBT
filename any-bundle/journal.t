#!/usr/bin/env bats

@test "journal does not contain: Cannot open pixbuf loader module file" {
    result="$(journalctl -b)"
    result2="$(echo $result | grep  'Cannot open pixbuf loader module file' | wc -l )"
    [ "$result2" == "0" ] 
}

@test "journal does not contain: libGL error: failed to load driver" {
    result="$(journalctl -b)"
    result2="$(echo $result | grep  'libGL error: failed to load driver' | wc -l )"
    [ "$result2" == "0" ] 
}

@test "journal does not contain: Direct firmware load for regulatory.db failed with error" {
    result="$(journalctl -b)"
    result2="$(echo $result | grep  'Direct firmware load for regulatory.db failed with error' | wc -l )"
    [ "$result2" == "0" ] 
}

@test "journal does not contain: invalid key/value pair in file " {
    result="$(journalctl -b)"
    result2="$(echo $result | grep  'invalid key/value pair in file' | wc -l )"
    [ "$result2" == "0" ] 
}

@test "journal does not contain: Process '/usr/bin/alsactl restore 1' failed with exit code 99." {
    result="$(journalctl -b)"
    result2="$(echo $result | grep  '/usr/bin/alsactl' | grep 'failed with exit code' | wc -l )"
    [ "$result2" == "0" ] 
}

@test "Failed to spawn Xwayland: Failed to execute child process" {
    result="$(journalctl -b)"
    result2="$(echo $result | grep  'Failed to spawn Xwayland: Failed to execute child process' | grep '/usr/bin/haswell/Xwayland' | wc -l )"
    [ "$result2" == "0" ] 
}

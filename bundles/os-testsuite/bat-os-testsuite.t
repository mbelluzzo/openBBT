#!/usr/bin/env bats
# *-*- Mode: sh; sh-basic-offset: 8; indent-tabs-mode: nil -*-*

@test "bats run " {
    bats -h
    echo "#!/usr/bin/env bats" > hello.t
    echo "@test 'ls' { " >> hello.t
    echo "ls" >> hello.t
    echo "}" >> hello.t
    bats hello.t
    rm -rf hello.t
}

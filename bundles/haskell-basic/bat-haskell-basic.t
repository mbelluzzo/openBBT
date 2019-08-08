#!/usr/bin/env bats

# haskell - basic test
# --------------
#
# Author      :   William Douglas
#
# Requirements:   bundle haskell-basic

@test "stack-basic" {
    stack setup
    stack exec env
    stack new project
    cd project
    stack install
    cd ..
    rm -fr project
    ~/.local/bin/project-exe
    rm -fr ~/.local/bin
    rm -fr ~/.stack
}

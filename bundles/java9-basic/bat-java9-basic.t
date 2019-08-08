#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*


# Java 9 - basic test
# --------------
#
# Author      :   Athenas Jimenez
#
# Requirements:   bundle Java9-basic
#

SRC="../../src/bat-java9-basic"

cleanup() {
    rm -rf .m2
    rm -rf HelloWorld.class
    rm -rf target
    rm -rf helloworld.jar
    rm -rf docs
}

setup() {
    pushd "$SRC"
    cleanup
}

teardown() {
    cleanup
    popd
}

@test "Compile and run Hello World" {
    javac9 HelloWorld.java
    java9 HelloWorld
}

@test "Create documentation with javadoc" {
    mkdir -p docs/
    javadoc9 -d ./docs/ HelloWorld.java
}

@test "Package a jar file" {
    jar9 -cf helloworld.jar HelloWorld.java
}

@test "Run a script in JShell" {
    jshell9 < twice.java
}

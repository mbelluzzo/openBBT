#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

# vim - basic tests
# -----------------
#
# Author      :   Jair Gonzalez
# Requirements:   vim
#

SRC="../../src/vim"
TEST_FILE_CONTENT=$(cat << END
This is the first line.
This is a second line.
This is a third line.
END
)
unset TEMP_DIR
unset TEST_FILE

cleanup() {
    if [ -e "$TEST_FILE" ]; then
        rm $TEST_FILE
    fi
    if [ -d "$TEMP_DIR" ]; then
        rmdir $TEMP_DIR
    fi
}

setup() {
    TEMP_DIR=$(mktemp -d)
    TEST_FILE=$(mktemp -u -p $TEMP_DIR)
}

teardown() {
    cleanup
}

@test "vim help-version" {
    /usr/bin/vim --help
    /usr/bin/vim --version
}

@test "vim write file" {
    run /usr/bin/vim -n $TEST_FILE +$'i\n'"$TEST_FILE_CONTENT" +w +q
    [ "$(< $TEST_FILE)" == "$TEST_FILE_CONTENT" ]
}

@test "vim ex-mode write file" {
    run /usr/bin/vim -n -e $TEST_FILE << END
i
$TEST_FILE_CONTENT
.
x
END
    [ "$(< $TEST_FILE)" == "$TEST_FILE_CONTENT" ]
}

@test "vimscript read-write file" {
    pushd $SRC
    run /usr/bin/vim -n $TEST_FILE -s ./test-vimscript.vim
    [ "$(< $TEST_FILE)" == "$(< ./expected.txt)" ]
    popd
}

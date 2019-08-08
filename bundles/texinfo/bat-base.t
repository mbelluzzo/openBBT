#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

setup() {
    export ORIGINAL_PWD=$PWD
    export TEST_TMP=$(mktemp -d)
    mkdir ${TEST_TMP}/test-workdir
    cd ${TEST_TMP}/test-workdir
}

teardown() {
    cd ${ORIGINAL_PWD}
    rm -r ${TEST_TMP}/test-workdir
    rmdir ${TEST_TMP}
}

@test "makeinfo" {

cat <<EOF > test.texi
\input texinfo   @c -*-texinfo-*-
@comment $Id@w{$}
@comment %**start of header
@settitle a makeinfo test
@syncodeindex pg cp
@comment %**end of header

@dircategory Texinfo documentation system
@direntry
* sample: (sample)Invoking sample.
@end direntry


@contents

@ifnottex
@node Top
@top

This doc is meat fo testing the texinfo  is for  Sample (version).
@end ifnottex

@menu
* texi in clear linux::
* chiales
* Index::
@end menu


@node texi in clear linux

@pindex sample
@cindex invoking @command{sample}

This is a sample test.

@appendix a test for makeinfo


@node Index
@unnumbered Index

@printindex cp

@bye
EOF

makeinfo test.texi
test -s test.info
grep -q "File: test.info,  Node: texi in clear linux,  Next: Index,  Prev: Top,  Up: To"  test.info
grep -q "Appendix A a test for makeinfo"  test.info

}


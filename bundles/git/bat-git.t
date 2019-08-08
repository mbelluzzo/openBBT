#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Git - basic test
# -----------------
#
# Authors     :   Josue David Hernandez Gutierrez
#                 Salvador Teran Ochoa
#
# Requirements:   bundle git
#

REPO_NAME="samplerepo"

@test "Ceate a git repo and clone it" {
    TMPDIR=$(mktemp -d)
    pushd $TMPDIR
    if [ "$(git config --global user.email)" == "" ]; then
        git config --global user.email "test@clearlinux.com"
        git config --global user.name "test clear linux"
    fi
    git init --bare ${REPO_NAME}.git
    git clone ${REPO_NAME}.git
    pushd ${REPO_NAME}
    echo "some text" > file_one
    git add .
    git commit -a -m "some text"
    git log | grep "some text"
    git push origin master
    git log | grep -E "commit [a-z0-9]+" | awk '{print $2}' | \
        grep -f ../${REPO_NAME}.git/refs/heads/master
    popd
    rm -rf ${REPO_NAME} ${REPO_NAME}.git
}

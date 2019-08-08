#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

# shells - basic test
# -----------------
#
# Author      :   Carlos Arturo Garcia Garcia
#
# Requirements:   shells
#

ZSHTEST=$(mktemp /tmp/XXXXX.sh)
TestFold="/tmp/test_fold1/test_fold2/test_fold3/"

setup() {
  ShellsFile="/usr/share/defaults/etc/shells"
  mkdir -p $TestFold
  touch $TestFold/target.txt
  echo "ls /tmp/test_fold1/**/target.txt" > $ZSHTEST
}

teardown () {
  rm -rf /tmp/test_fold1
}

@test "bat-shells: shells file exist" {
  [ -e $ShellsFile ]
}


@test "bat-shells: validate shell files exist and are executable" {
  while read -r name; do
   case "$name" in
     ("#"*) ;; #ignore comments
     (*"tmux") ;; #ignore tmux
     (*) [ -x "$name" ]
    esac;
  done < $ShellsFile
}

@test "bat-shells: run a script in zsh and must pass" {
  zsh $ZSHTEST
}

@test "bat-shells: run a script in bash and must fail" {
  ! bash $ZSHTEST
}

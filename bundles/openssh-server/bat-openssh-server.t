#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# openssh-server - basic test
# -----------------
#
# Author      :   Carlos Arturo Garcia Garcia
#
# Requirements:   openssh-server
#

setup() {
  Newuser="dummy"
  PASS="FakePass"
  TMPDIR="/tmp/source"
  Newkey="$TMPDIR/new_key"
  FILE="cp_me.txt"
  SCP_FILE="/tmp/source/$FILE"
  SCP_DEST="/home/$Newuser"
}

@test "bat-openssh-server: create a ssh-key" {
  if ! grep -q dummy /etc/shadow; then
    useradd dummy
    echo dummy:FakePass | chpasswd
  fi
  mkdir $TMPDIR
  touch $SCP_FILE
  ssh-keygen -t rsa -f $Newkey -q -N ""
}

@test "bat-openssh-server: copy keys for another user" {
  mkdir -p $SCP_Dest/.ssh
  cat $Newkey.pub > $SCP_DEST/.ssh/authorized_keys
  chown -R "$Newuser":"$Newuser" "$SCP_DEST/.ssh"
  chmod -R 600 "$SCP_DEST/.ssh"
  chmod 700 "$SCP_DEST/.ssh"

}

@test "bat-openssh-server: login to new user account using keys" {
  ssh -i $Newkey -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $Newuser@localhost "exit"
}

@test "bat-openssh-server: scp a file " {
  scp -i $Newkey -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SCP_FILE $Newuser@localhost:$SCP_DEST
  ssh -i $Newkey -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $Newuser@localhost "ls $SCP_DEST/$FILE"
}

@test "bat-openssh-server: cleanup" {
  if grep -q dummy /etc/shadow; then
    userdel -r -f dummy
  fi
  rm -rf $TMPDIR
}

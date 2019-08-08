#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# desktop-apps-extras - basic test
# -----------------
#
# Author      :   Jair de Jesus Gonzalez Plascencia
#
# Requirements:   bundle desktop-apps-extras
#

@test "geany help-version" {
  geany --help
  geany --version
}

@test "gimp help-version" {
  gimp --help
  gimp --version
}

@test "gmic help-version" {
  gmic --help
  gmic --version
}

@test "gphoto2 help-version" {
  gphoto2 --help
  gphoto2 --version
}

@test "hexchat help-version" {
  hexchat --help
  hexchat --version
}

@test "pidgin help-version" {
  pidgin --help
  pidgin --version
}

@test "thunderbird help-version" {
  thunderbird --help
  thunderbird --version
}

@test "virt-viewer help-version" {
  virt-viewer --help
  virt-viewer --version
}

@test "vlc help-version" {
  if [ $(id -u) = 0 ]; then
    skip "this test cannot be run as root"
  fi

  vlc --help
  vlc --version
}

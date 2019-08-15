#!/usr/bin/env bats
# clr-installer test
# --------------
#
# Author      :   Salvador Teran
#
# Requirements:   bundle clr-intaller

CONF="../../src/bat-clr-installer/min-good.yaml"

setup() {
    if grep -q '^VERSION_ID=1$' /usr/lib/os-release; then
        source ../../utils/swupd.bash
        ln -s $SWUPD_CERT /usr/share/clear/update-ca/Swupd_Root.pm
    fi
    STATE_DIR=$(mktemp -d)
}

teardown() {
    rm -rf "$STATE_DIR" kvm.img
}

@test "clr-installer minimal install" {
    clr-installer -c "$CONF" --swupd-state "$STATE_DIR" --log-level 4
}

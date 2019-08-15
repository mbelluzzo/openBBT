#!/usr/bin/env bats
# clr-installer install TUI minimal
# --------------
#
# Author      :   Mark Horn
#
# Requirements:   bundle clr-installer tcl

EXP="../../src/bat-clr-installer/clr-install-tui-basic.exp"
IMG=${IMG:-"min-install.img"}
IMG_SIZE=${IMG_SIZE:-"4G"}
WORK_DIR=$PWD
INSTDEV=""

setup() {
    [ -e /var/tmp/proxies ] && source /var/tmp/proxies
    if grep -q '^VERSION_ID=1$' /usr/lib/os-release; then
        source ../../utils/swupd.bash
        ln -s $SWUPD_CERT /usr/share/clear/update-ca/Swupd_Root.pm
    fi

    # Remove old image if present
    rm -f ${WORK_DIR}/${IMG}

    # Make target image file
    /usr/bin/qemu-img create -f raw ${WORK_DIR}/${IMG} ${IMG_SIZE}

    # Make the image file available
    INSTDEV=$(losetup --find --show ${WORK_DIR}/${IMG})
    partprobe ${INSTDEV}
}


teardown() {
    # Clean-up the image file
    losetup -d ${INSTDEV}
    rm -f ${WORK_DIR}/${IMG}
}

@test "clr-installer tui basic install" {
    expect ${EXP}
}

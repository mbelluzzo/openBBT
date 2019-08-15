#!/usr/bin/env bats
# clr-installer build check test
# --------------
#
# Author      :   Mark Horn
#
# Requirements:   bundle clr-installer

setup() {
    if grep -q '^VERSION_ID=1$' /usr/lib/os-release; then
        source ../../utils/swupd.bash
        ln -s $SWUPD_CERT /usr/share/clear/update-ca/Swupd_Root.pm
    fi

    git clone https://github.com/clearlinux/clr-installer.git git-clr-installer
}


teardown() {
    rm -rf git-clr-installer
}

@test "clr-installer build check" {
    cd git-clr-installer
    make check
    cd ..
}

#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# service-os - ACRN setup
# -----------------
#
# Author      :   Libertad Gonzalez
#
# Requirements:   bundle kernel-pk service-os
#

@test "downloading kvm image" {
	clrVersion=$(swupd info | grep "version" | awk -F': ' '{ print $2}')
	mkdir -p $HOME/kvmImages
	cd $HOME/kvmImages
	curl -O https://download.clearlinux.org/releases/"$clrVersion"/clear/clear-"$clrVersion"-kvm.img.xz
	unxz clear-"$clrVersion"-kvm.img.xz
	losetup -f -P --show $HOME/kvmImages/clear-"$clrVersion"-kvm.img
	mount /dev/loop0p3 /mnt
	standardModules=$(ls /usr/lib/modules | grep standard | sort -r | head -1)
	cp -r /usr/lib/modules/"$standardModules" /mnt/lib/modules/
	umount /mnt
	losetup -D
	sync
	cd /usr/share/acrn/samples/nuc/
	sed -i -e s/clear-[0-9]*-kvm.img/clear-"$clrVersion"-kvm.img/g launch_uos.sh2
	oldKernel=$(grep org.clearl launch_uos.sh2  | awk -F'/' '{print $5}' | awk -F' ' '{print $1}')
	newKernel=$(ls /usr/lib/kernel/ | grep org.clearlinux | sort -r | grep standard | head -1)
	sed -i -e s/"$oldKernel"/"$newKernel"/g launch_uos.sh2
	acrnctl add launch_uos.sh2 2
}

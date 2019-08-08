#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
# service-os - ACRN setup
# -----------------
#
# Author      :   Libertad Gonzalez
#
# Requirements:   bundle kernel-pk service-os
#

@test "ACRN setup" {
      run swupd update -F staging 2>&1
      if [ "$status" -eq 0 ]; then
           swupd bundle-add vim network-basic service-os kernel-pk desktop openssh-server 2>&1 || true
           swupd autoupdate --disable
           mountPoint=$(fdisk -l | grep "EFI System" | awk -F' ' '{print $1}')
           mount $mountPoint /mnt/
           mkdir -p /mnt/EFI/acrn
           cp /usr/lib/acrn/acrn.efi /mnt/EFI/acrn/
           efibootmgr -c -l "\EFI\acrn\acrn.efi" -d /dev/sda -p 1 -L "ACRN"
           cp /usr/share/acrn/samples/nuc/acrn.conf /mnt/loader/entries/
           newKernel=$(ls /mnt/EFI/org.clearlinux/| grep 'sos' | sort -nr | head -n1)
           oldKernel=$(grep ^linux /mnt/loader/entries/acrn.conf  | awk -F'/' '{ print $4 }')
           sed -i -e s/"$oldKernel"/"$newKernel"/g /mnt/loader/entries/acrn.conf
           sed -i -e s/"i915.enable_initial_modeset=1"/""/g /mnt/loader/entries/acrn.conf
           sed -i -e s/"<UUID of rootfs partition>"/"$(blkid | grep sda3 | awk -F' ' '{print $5}' | awk -F'\"' '{print $2}')"/g /mnt/loader/entries/acrn.conf
           sh -c 'echo -e "timeout 5 \\ndefault acrn" > /mnt/loader/loader.conf'
      fi
}

#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# service-os - ACRN setup
# -----------------
#
# Author      :   Libertad Gonzalez
#
# Requirements:   bundle kernel-pk service-os
#

@test "ACRN setup update" {
      mountPoint=$(fdisk -l | grep "EFI System" | awk -F' ' '{print $1}')
      mount $mountPoint /mnt/
      run swupd update -F staging 2>&1
      if [ "$status" -eq 0 ]; then
              cp /usr/lib/acrn/acrn.efi /mnt/EFI/acrn/
              newKernel=$(ls /mnt/EFI/org.clearlinux/| grep 'sos' | sort -nr | head -n1)
              oldKernel=$(grep ^linux /mnt/loader/entries/acrn.conf  | awk -F'/' '{ print $4 }')
              sed -i -e s/"$oldKernel"/"$newKernel"/g /mnt/loader/entries/acrn.conf
              sh -c 'echo -e "timeout 5 \\ndefault acrn" > /mnt/loader/loader.conf'
              bootOrder=$(efibootmgr -v | grep 'ACRN' | cut -b 5,6,7,8 | sort -r | head -1)
              efibootmgr -o "$bootOrder"
              swupd autoupdate --disable
      fi
}

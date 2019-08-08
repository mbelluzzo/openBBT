#!/bin/bash
# -----------------
#
# Author      :   Libertad Gonzalez
#
# Requirements:   Apolo Lake NUC, with ACRN installed and ready to be updated
#

param=$1

hardware=$(dmidecode | grep -A 3 "System Information" | grep "Product Name:"  | awk -F': ' '{print $2}')


if [ "$hardware" = "NUC6CAYS" ] || [ "$hardware" = "NUC6CAYB" ] || [ "$hardware" = "NUC6CAYH" ]; then

mkdir -p "/var/log/acrnTest"

case "$param" in

         setup-acrn)

            sh -c 'prove -vvv bat-acrn-setup.t > /var/log/acrnTest/ACRN_setupLog.t'
            if [ $? -eq 0 ]; then
              reboot
            else
             echo 'Test failed see log /var/log/acrnTest/ACRN_setupLog.t'
             exit 1
            fi
           ;;
         update-acrn)

            sh -c 'prove -vvv bat-acrn-update.t > /var/log/acrnTest/ACRN_updateLog.t'
            if [ $? -eq 0 ]; then
               reboot
            else
               echo 'Test failed see log /var/log/acrnTest/ACRN_updateLog.t'
               exit 1
            fi
            ;;

         start_uos)

            sh -c 'prove -vvv bat-UOS-launch.t > /var/log/acrnTest/UOS_launchLog.t'
	    acrnctl start vm2 &
            ;;

         check_kernel)

            sh -c 'prove -vvv bat-kernel-pk.t > /var/log/acrnTest/kernelCheckLog.t'
            ;;

         acrnctl_tool)

            sh -c 'prove -vvv bat-acrnctl.t > /var/log/acrnTest/acrnctlLog.t'
            ;;

         *)
         echo $"Usage: $0 {setup-acrn|update-acrn|start_uos|check_kernel|acrnctl_tool}"
         exit 1

 esac

fi

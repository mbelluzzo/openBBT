#!/bin/bash
TYPE=$1
#Create a work directory
mkdir -p /var/taas/bios
#copy required files
cp *.xml /var/taas
#Get img file and OVMF.fd file
pushd /var/taas
if [ "$TYPE" == "live" ]; then
    curl https://download.clearlinux.org/image/ | grep "live-server.iso.xz" > TMP.txt
    RELNUM=$(cat TMP.txt | awk -F"-" '{print $2}' | head -n1)
    curl -Ok  https://cdn.download.clearlinux.org/releases/$RELNUM/clear/clear-$RELNUM-live-server.img.xz
    unxz clear-$RELNUM-live-server.img.xz
    qemu-img convert -f raw -O qcow2 clear-$RELNUM-live-server.img  clear-$RELNUM-live.qcow2
    sed -i "s/RELEASE/$RELNUM/" ClearLIVE-BBT.xml
else
    curl https://download.clearlinux.org/image/ | grep "kvm.img.xz" > TMP.txt
    RELNUM=$(cat TMP.txt | awk -F"-" '{print $2}' | head -n1)
    curl -Ok curl https://cdn.download.clearlinux.org/releases/$RELNUM/clear/clear-$RELNUM-kvm.img.xz
    unxz clear-$RELNUM-kvm.img.xz
    qemu-img convert -f raw -O qcow2 clear-$RELNUM-kvm.img  clear-$RELNUM-kvm.qcow2
    sed -i "s/RELEASE/$RELNUM/" ClearKVM-BBT.xml
fi
cp -f /usr/share/qemu/OVMF.fd .
chmod 777 OVMF.fd
mv OVMF.fd bios/
popd

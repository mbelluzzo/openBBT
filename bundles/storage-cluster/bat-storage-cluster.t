#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# storage-cluster - basic test
# -----------------
#
# Author      :   Carlos Arturo Garcia Garcia
#
# Requirements:   storage-cluster
#

SRC="../../src/bat-storage-cluster"
CLUSTERNAME="ceph"
MYIP=127.0.0.1
MYNAME=$HOSTNAME
FSID=$(uuidgen)
CEPHDIR="/var/lib/ceph"
BOOTSTRAPDIR="$CEPHDIR/bootstrap-osd"
DATADIR="$CEPHDIR/mon/$CLUSTERNAME-$MYNAME"
CONFDIR="/etc/ceph"

setup () {
if [ ! -e $CONFDIR/ceph.conf ];
then
	mkdir -p $CONFDIR
	cp $SRC/ceph.conf $CONFDIR/ceph.conf
	pushd $CONFDIR
	sed -i "s/MON_FSID/$FSID/" ceph.conf
	sed -i "s/MON_IP/$MYIP/" ceph.conf
	sed -i "s/MON_NAME/$MYNAME/" ceph.conf
	popd
fi
}

@test "bat-storage-cluster: generate cluster keyring and monitor key" {
	ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
}

@test "bat-storage-cluster: generate admin keyring and user" {
	ceph-authtool --create-keyring $CONFDIR/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
}

@test "bat-storage-cluster: generate boostrap user and keyring" {
	mkdir -p $BOOTSTRAPDIR
	ceph-authtool --create-keyring $BOOTSTRAPDIR/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'
}

@test "bat-storage-cluster: add keys to keyring" {
	ceph-authtool /tmp/ceph.mon.keyring --import-keyring $CONFDIR/ceph.client.admin.keyring
	ceph-authtool /tmp/ceph.mon.keyring --import-keyring $BOOTSTRAPDIR/ceph.keyring
}

@test "bat-storage-cluster: create monitor map" {
	monmaptool --create --add $MYNAME $MYIP --fsid $FSID /tmp/monmap
}

@test "bat-storage-cluster: create and populate data directories" {
	mkdir -p $DATADIR
	ceph-mon --mkfs -i $MYNAME --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
	chown -R ceph:ceph $CEPHDIR
}

@test "bat-storage-cluster: start monitor service" {
	export CLUSTER=ceph
	systemctl start ceph-mon@$MYNAME
}

@test "bat-storage-cluster: check monitor service status" {
for i in `seq 1 15`;
	do
	sleep 2 
	res=$(systemctl is-active ceph-mon@$MYNAME | grep active)
	if [ "$res" == "active" ] 
	then
	  break
	fi   
done
}

@test "bat-storage-cluster: cleanup" {
	systemctl stop ceph-mon@$MYNAME
	rm -rf $CONFDIR
	rm -rf $CEPHDIR
	rm -rf /tmp/ceph.mon.keyring
	rm -rf /tmp/monmap
}

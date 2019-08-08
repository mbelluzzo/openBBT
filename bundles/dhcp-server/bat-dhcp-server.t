#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# DHCP Server - basic test
# -----------------
#
# Author      :   Salvador Teran Ochoa
#
# Requirements:   bundle dhcp-server
#

SRC="../../src/bat-dhcp-server"

@test "activate service" {
        [ -f /etc/dnsmasq.conf ] && skip
	systemctl is-active -q dnsmasq.service && skip
        cp $SRC/dnsmasq.conf /etc/dnsmasq.conf
        systemctl start dnsmasq.service
        sleep 5
        run systemctl is-active -q dnsmasq.service
        [ $status = 0 ]
}

@test "dnsmasq --test" {
        cmp -s "$SRC/dnsmasq.conf" /etc/dnsmasq.conf || skip
        dnsmasq --test
}

@test "service is inactive" {
        cmp -s "$SRC/dnsmasq.conf" /etc/dnsmasq.conf || skip
        systemctl stop dnsmasq.service
        sleep 5
        run systemctl is-active -q dnsmasq.service
        [ $status != 0 ]
	rm /etc/dnsmasq.conf
}

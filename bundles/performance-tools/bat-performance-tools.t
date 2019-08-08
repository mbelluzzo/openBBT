#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Author      :   Victor Rodriguez
#
# Requirements:   bundle performance-tools
#
#   Missing ones:
#
#   procps-ng -h
#   net-tools -h
#   sysstat -h
#   iotop -h
#   slabtop -o
#

@test "agentstrap" {
        agentxtrap -h
}

@test "collectl" {
        CONF='/etc/collectl.conf'
        touch $CONF
        collectl -h
        [ -s $CONF ] || rm $CONF
}

@test "dstat" {
        dstat -h
}

@test "dstat systemd" {
        pidstat -C systemd | grep systemd
}

@test "dstat display" {
        pidstat -d
}

@test "encode_keychange" {
        encode_keychange -h
}

@test "ethtool" {
        ethtool -h
}

@test "fixproc" {
        CONF='/local/etc/fixproc.conf'
        if [ ! -f ${CONF} ]; then
                mkdir -p /local/etc
                touch ${CONF}
                sleep 3 &
                PROC=$!
                fixproc -kill ${PROC}
                rm ${CONF}
                rmdir /local/etc || :
                rmdir /local || :
        else
                sleep 3 &
                PROC=$!
                fixproc -kill ${PROC}
        fi
}

@test "gperf" {
        gperf -h
}

@test "htop" {
        htop -h
}

@test "iostat -h" {
        iostat -h
}

@test "iostat -c" {
        iostat -c
}

@test "iostat -d" {
        iostat -d
}

@test "iostat -n" {
        iostat -N
}

@test "iostat -m" {
        iostat -m
}

@test "iostat -p sda" {
        iostat -p sda
}

@test "iostat -p" {
        iostat -p
}

@test "iostat -x" {
        iostat -x
}

@test "iostat -N" {
        iostat -N
}

@test "iptraf" {
        iptraf -h
}

@test "mib2c" {
        mib2c -h | grep "This message"
}

@test "micb2c-update" {
        pushd /tmp
        echo "UPDATE_CONF=mib2c.mfd.conf" > .mib2c-updaterc
        echo "UPDATE_OID=ipAddressTable" >> .mib2c-updaterc
        mib2c-update -h | grep "This message"
        popd
}

@test "mpstat -P ALL" {
        mpstat -P ALL
}

@test "mpstat -P 0" {
        mpstat -P 0
}

@test "mpstat -P (number of CPUs)" {
        CPU=$(($(lscpu | grep "^CPU(s):" | awk '{print $2}')-1))
        mpstat -P $CPU
}

@test "mpstat -A" {
        mpstat -A
}

@test "mpstat -V" {
        mpstat -V
}

@test "msr-cpuid" {
        if [ "$EUID" -eq 0 ] ; then
                msr-cpuid
        else
                skip
        fi
}

@test "net-snmp" {
        net-snmp-cert -V
}

@test "net-snmp=config" {
        net-snmp-config -V
}

@test "net-snmp-v3" {
        net-snmp-create-v3-user -V
}

@test "netstat -plnt" {
        netstat -plnt
}

@test "nicstat" {
        nicstat
}

@test "powertop" {
        powertop -h
}

@test "powertop csv 2s report" {
        powertop -C -t 2
        [ -f powertop.csv ] && rm powertop.csv
}

@test "psstop" {
        psstop -h
}

@test "rdmsr" {
        rdmsr --version
}

@test "rvnamed" {
        skip "skip for now"
        rvnamed -h
}
@test "snmp-bridge" {
        snmp-bridge-mib
        rm -rf /var/net-snmp
}

@test "snmpbulkget" {
        snmpbulkget -V
}

@test "snmpbulwalk" {
        snmpbulkwalk -V
}

#@test "snmp-check" {
#        snmpcheck -V
#}

@test "snmp-conf" {
        snmpconf -h
}

@test "snmpd" {
        snmpd -v
}

@test "snmpdelta" {
        snmpdelta -V
}

@test "snmpf" {
        snmpdf -V
}

@test "shmpget" {
        snmpget -V
}

@test "snmpinform" {
        snmpinform -V
}
    
@test "snmpwalk" {
        snmpwalk -V
}

@test "sysstat-cifsiostat" {
        cifsiostat -h 
}

@test "sysstat-mpstat" {
        mpstat -V
}

@test "sysstat-pidstat" {
        pidstat -h
}

@test "sysstat-sadf" {
        sadf -V
}

@test "sysstat-sar" {
        sar -V
}

@test "sysstat-tapstat" {
        tapestat -V
}

@test "tcpdump" {
        tcpdump -h
}

@test "tiptop" {
        tiptop -h
}

@test "tiptop -n 1" {
        tiptop -n 1
}

@test "tkmib" {
        tkmib -h
}

@test "traptoemail" {
        traptoemail -h
}

@test "vmstat help" {
        vmstat -h
}

@test "vmstat -a" {
        vmstat -a
}

@test "vmstat -D" {
        vmstat -D
}

@test "vmstat -m" {
        vmstat -m
}

@test "wrmsr" {
        wrmsr --help
}

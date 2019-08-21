#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

## DBUS ##
@test "dbus-1/session.conf file in /usr/share/" {
    [[ -f '/usr/share/dbus-1/session.conf' ]]
}

@test "dbus-1/system.conf file in /usr/share/" {
    [[ -f '/usr/share/dbus-1/system.conf' ]]
}

@test "dbus-1/system.d directory in /usr/share/" {
    [[ -d '/usr/share/dbus-1/system.d' ]]
}

## OS-RELEASE
@test "os-release file in /usr/lib" {
    [[ -f /usr/lib/os-release ]]
}

## PAM SECURITY
@test "security directory exists in /usr/share" {
    [[ -d /usr/share/security ]]
}

## PASSWD ##
@test "no root in /etc/passwd" {
    ! grep -q root /etc/passwd
}

@test "getent passwd root works" {
    result=$(getent passwd root 2>/dev/null)
    [[ "$result" = "root:x:0:0:root:/root:/bin/bash" ]]
}

## ETC ##
@test "machine-id" {
    [[ -f '/etc/machine-id' ]]
}

@test "mtab" {
    [[ -L '/etc/mtab' ]]
}

@test "resolv.conf" {
    [[ -L '/etc/resolv.conf' ]]
}

@test "ssl" {
    [[ -d '/etc/ssl' ]]
}

## VAR ##
@test "cache" {
    [[ -d '/var/cache' ]]
}

@test "empty" {
    [[ -d '/var/empty' ]]
}

@test "lib" {
    [[ -d '/var/lib' ]]
}

@test "lock" {
    [[ -L '/var/lock' ]]
}

@test "journal" {
    [[ -d '/var/log/journal' ]]
}

@test "run" {
    [[ -L '/var/run' ]]
}

@test "spool" {
    [[ -d '/var/spool' ]]
}

@test "tmp" {
    [[ -d '/var/tmp' ]]
}

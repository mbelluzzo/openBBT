#!/bin/sh
# *-*- Mode: sh; sh-basic-offset: 8; indent-tabs-mode: nil -*-*
create_backup() {
        compression=${1-none}
        encryption=${2-none}
        rm -rf repo
        borg init -e $encryption repo
        borg create -C $compression repo::test1 data
        borg check repo
}

extract_and_check() {
        rm -rf extracted
        mkdir extracted
        (cd extracted;
         borg extract ../repo::test1 && sha1sum data/*) | sha1sum -c
}

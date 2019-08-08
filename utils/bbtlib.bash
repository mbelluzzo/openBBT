#!/usr/bin/bash
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

# Source this file from a BATS test file

timeout_test() {
    local test_function="$1"
    local timeout="$2"

    set +e
    for i in $(seq 1 "${timeout}"); do
        sleep 1
        eval "${test_function}"
	if [ $? -eq 0 ]; then
	    break
	elif [ "${i}" == "${timeout}" ]; then
            set -e
            echo "${test_function} timed out after ${timeout} seconds"
            return 1
        fi
    done
    set -e
}

systemctl_check_start() {
    local unit="$1"

    set +e
    systemctl start "${unit}"
    systemctl is-active --quiet "${unit}"
    if [ $? -ne 0 ]; then
        set -e
        echo "${unit} failed to start"
        return 1
    fi
    set -e
}

systemctl_check_stop() {
    local unit="$1"

    set +e
    systemctl stop "${unit}"
    systemctl is-failed --quiet "${unit}"
    local err=$?
    set -e
    if [ $err -eq 0 ]; then
        echo "${unit} failed during stop"
        return 1
    fi
}

systemctl_check_is_active() {
    local unit="$1"

    set +e
    systemctl is-active --quiet "${unit}"
    set -e
    if [ ! $? -eq 0 ]; then
        echo "${unit} is not active"
        return 1
    fi
}

check_files_exist() {
    local path="$1"
    shift
    local files=("$@")

    if [ -z "${files}" ]; then
        echo "test error: file list is empty"
        return 1
    fi
    set +e
    local status=0
    for file in "${files[@]}" ; do
        if [ ! -f "${path}/${file}" ]; then
            [ ! -z "${path}" ] \
                && echo "${file} not found in ${path}" \
                || echo "${file} not found"
            status=1
        fi
    done
    set -e
    return "${status}"
}

check_file_globs() {
    local path="$1"
    shift
    local globs=("$@")

    if [ -z "${globs}" ]; then
        echo "test error: glob list is empty"
        return 1
    fi
    set +e
    local status=0
    for glob in "${globs[@]}" ; do
        ls ${path}/${glob} 1> /dev/null 2>&1
        if [ $? -ne 0 ]; then
            [ ! -z "${path}" ] \
                && echo "${path}/${glob} not found" \
                || echo "${glob} not found"
            status=1
        fi
    done
    set -e
    return "${status}"
}

get_autoupdate_state() {
    run systemctl is-enabled swupd-update.service > /dev/null
    echo "${status}"
}

set_autoupdate_state() {
    local AUTOUPDATE="$1"
    if [[ $AUTOUPDATE -eq 0 ]]; then
        systemctl unmask --now swupd-update.service swupd-update.timer && /usr/bin/systemctl start swupd-update.timer > /dev/null
    else
        systemctl mask --now swupd-update.service swupd-update.timer > /dev/null
    fi
}

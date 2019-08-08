#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# devpkg-base test suite
# -----------------
#
# Author      :   Jair Gonzalez
#
# Requirements:   bundle devpkg-base
#

@test "pkg-config help version" {
    pkg-config --help
    pkg-config --version
}

@test "pkg-config cflags" {
    pkg-config --cflags pkg-config
}

@test "pkg-config compare known packages against pc_path files" {
    local pc_list=( $(pkg-config --list-all | awk '{print $1".pc"}' | sort -u) )
    local pc_path="$(pkg-config --variable=pc_path pkg-config)"
    [[ ":${pc_path}:" != *":${PKG_CONFIG_PATH}:"* ]] && pc_path="${pc_path}:${PKG_CONFIG_PATH}"
    local pc_paths=$(echo "${pc_path}" | tr ":" "\n")
    # Ensure removing path grouping headers from ls output
    local path_pc_list=( $(ls -1 ${pc_paths} | grep -E "^[^/].*\.pc" | sort) )
    local diff=$(comm -3 <(printf '%s\n' ${pc_list[@]}) <(printf '%s\n' ${path_pc_list[@]}))
    if [ ! -z "${diff}" ]; then
        echo "test failed: non tracked package config files found:"
        echo "${diff}"
        return 1
    fi
}

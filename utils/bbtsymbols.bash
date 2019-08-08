#!/usr/bin/bash
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

# Source this file from a BATS test file

nm_bin="$(command -v nm || :)"

validate_requirements() {
    if [ ! -f "$nm_bin" ]; then
        echo "bbtsymbols error: nm binary is required" 1>&2
        return 1
    fi
}

get_dependencies() {
    local path="$1"
    shift
    local globs=("$@")

    if [ -z "${globs}" ]; then
        echo "test error: glob list is empty"
        return 1
    fi
    for glob in ${globs[@]} ;
    do
        LD_TRACE_LOADED_OBJECTS=1 /lib64/ld-linux-x86-64.so.2 "${glob}" \
            | sed -ne 's/^\t\(.* => \)\([^ ]*\) (.*/\2/p'
    done
}

get_symbols() {
    local path="$1"
    shift
    local globs=("$@")

    if [ -z "${globs}" ]; then
        echo "test error: glob list is empty"
        return 1
    fi
    for glob in ${globs[@]} ;
    do
        nm -D --defined-only "${path}/${glob}" \
            | sed -ne 's/.*[ ]\+. \([^ \t@]\+\)\(@@.*$\|.*$\)/\1/p'
    done
}

get_undefined_symbols() {
    local path="$1"
    shift
    local globs=("$@")

    if [ -z "${globs}" ]; then
        echo "test error: glob list is empty"
        return 1
    fi
    for glob in ${globs[@]};
    do
        LD_TRACE_LOADED_OBJECTS=1 LD_WARN=yes LD_BIND_NOW=yes \
            /lib64/ld-linux-x86-64.so.2 \
            "${path}/${glob}" 2>&1 \
            | sed -ne 's/^undefined symbol: \([^ \t@]\+\)\(@@.*$\|.*$\)/\1/p'
    done
}

###
# Validate undefined symbols against globals found in the designed locations.
# If no expected global symbol locations are provided, validate that no
# undefined symbols are found in the files to validate.
#
# - The first argument is a reference to an array that contains globbing
#   expressions that match the files to validate.
# - The second argument is a reference to an array that contains globbing
#   expressions that point to the libraries and binaries where the undefined
#   symbols should be defined. The function also obtains the global symbols
#   found in the first level of dynamic libraries linked against the provided
#   binaries/libraries.
###
validate_symbols() {
    local -n globs_to_validate=$1
    local -n expected_locations=$2

    if [ ${#globs_to_validate[@]} -eq 0 ]; then
        echo "test error: glob list is empty"
        return 1
    fi
    local symbols_found=()
    if [ ! ${#expected_locations[@]} -eq 0 ]; then
        local bin_deps=$(get_dependencies "" "${expected_locations[@]}" \
            | sort -u | tr '\n' ' ')
        local symbol_locations=( ${expected_locations[@]} ${bin_deps[@]} )

        local symbols_found=$(get_symbols "" "${symbol_locations[@]}" \
            | sort -u)
    fi

    local undef_symbols=$(get_undefined_symbols "" "${globs_to_validate[@]}" \
        | sort -u)

    local diff=$(comm -23 <(echo "${undef_symbols}") <(echo "${symbols_found}") )

    if [ ! -z "${diff}" ]; then
        echo "test failed: undefined symbols were found:"
        echo "${diff}"
        return 1
    fi
}

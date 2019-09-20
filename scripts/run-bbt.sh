#!/usr/bin/env bash
# Copyright (C) 2018 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

BUNDLES=${BUNDLES:-$(ls -1 /usr/share/clear/bundles)}

for bundle in ${BUNDLES}; do
    test_list=$(ls -1 "${SCRIPT_DIR}/../bundles/${bundle}"/*.t 2> /dev/null)

    for t in ${test_list}; do
        bats -t "${t}"
    done
done

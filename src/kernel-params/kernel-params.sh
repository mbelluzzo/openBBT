#!/usr/bin/bash
kernel_name=$(uname -r)
[ -f "/usr/lib/kernel/cmdline-${kernel_name}" ] || exit 1
for param in $(cat /usr/lib/kernel/cmdline-${kernel_name}); do
    grep '\<'"$param"'\>' /proc/cmdline || exit 1
done

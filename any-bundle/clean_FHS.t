#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

@test "not files on root" {
    out=$(find / -maxdepth 1 -type f -ls)
    echo "$out"
    [ -z "$out" ]
}

@test "No content in /usr/local" {
	TMP_FILE="$(mktemp)"
	find /usr/local ! -type d > "$TMP_FILE"
	cat "$TMP_FILE"
	[ ! -s "$TMP_FILE" ]
	rm -f "$TMP_FILE"
}

@test "/usr/etc/: should not exist" {
    find /usr/etc || :
    [ ! -d /usr/etc ]
}

@test "/builddir: must not exist (BLOCKS RELEASE)" {
    [ ! -d /builddir ]
}

@test "/usr/lib64/avx2: should not exist" {
    [ ! -d /usr/lib64/avx2 ]
}

@test "/usr/{bin,lib64}/haswell/haswell should not exist" {
    [ ! -d /usr/bin/haswell/haswell ]
    [ ! -d /usr/lib64/haswell/haswell ]
}

@test "/var/run: should be a symlink" {
    [ -L /var/run ]
}

@test "no orphan libraries in /usr/lib" {
    out=$(find /usr/lib/ -maxdepth 1 -type f -name "*.so*" -ls)
    echo "$out"
    [ -z "$out" ]
}

@test "/usr/bin: undefined symbols" {
    NUM=0
    for b in /usr/bin/*; do
        output=$(ldd -r "$b" 2> /dev/null | sed -ne 's/^undefined symbol: \([^ \t@]\+\).*$/\t\1/p')
        if [[ -n "$output" ]]; then
            echo "undefined symbols for $b:"
            echo "$output"
            NUM=$((NUM+1))
        fi
    done
    [ $NUM -eq 0 ]
}

@test "/usr/bin/: unresolved libraries" {
    NUM=0
    for b in /usr/bin/*; do
        output=$(ldd "$b" 2> /dev/null | sed -ne 's/^\t\([^ ]*\)[ \t]\+.*not found.*$/\t\1/p')
        if [[ -n "$output" ]]; then
            echo "unresolved libraries for $b:"
            echo "$output"
            NUM=$((NUM+1))
        fi
    done
    [ $NUM -eq 0 ]
}

@test "no broken symlinks in /usr/bin" {
    links=$(find /usr/bin -xtype l -ls)
    echo "$links"
    [ -z "$links" ]
}

@test "no broken symlinks in /usr/lib64" {
    links=$(find /usr/lib64 -xtype l -ls)
    echo "$links"
    [ -z "$links" ]
}

@test "all kernels have a bundle associated" {
    for k in /usr/lib/kernel/org.clearlinux.* ; do
       [ -f "$k" ] || continue                  # Skip if it is not a file
       T=${k#/usr/lib/kernel/org.clearlinux.}   #remove up to org.clearlinux.
       T=${T%%.*}                               # remove from first dot
       #test we have the bundle
       [ -f "/usr/share/clear/bundles/kernel-$T" ] || (echo "kernel $T has no associated bundle; exit 1")
    done
}

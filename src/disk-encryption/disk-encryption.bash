#!/usr/bin/sh
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Disk encryption
# -----------------
#
# Author      :   Jair Gonzalez
#
# Requirements:   bundle storage-utils
#

# Global constants
map_name="tmp"
map_path="/dev/mapper"
map_dev="$map_path/$map_name"
test_file="test.txt"
passphrase="This is a plain text password. 5511>"
passphrase2="This is another password.#"
test_text="Lorem ipsum dolor sit amet, consectetur adipiscing elit."
python_test_mod="disk_encryption"
python3_bin="$(command -v python3 || :)"

setup_temp_inodes() {
    temp_dir="$(mktemp -d)"
    img_file="$(mktemp)"
    key_file="$(mktemp)"
    key2_file="$(mktemp)"
    echo -n "$passphrase" > $key_file
    echo -n "$passphrase2" > $key2_file
    echo "Temporal dir created: $(ls -d $temp_dir)"
    echo "Temporal files created: $(ls $img_file $key_file $key2_file)"
}

setup_loop_device() {
    if [ -f "$img_file" ]; then
        dd if=/dev/zero of="$img_file" bs=1M count=256
        loop_dev="$(losetup -f -P --show $img_file)"
        echo "Loop device attached: $(ls $loop_dev)"
    fi
}

unmount_unmap_detach_loop_device() {
    if mount | grep "$temp_dir" > /dev/null; then
        umount "$temp_dir"
        echo "Device unmounted"
    fi
    if [ -b "$map_dev" ]; then
        cryptsetup luksClose "$map_name"
        echo "Device unmapped"
    fi
    if [ -b "$loop_dev" ]; then
        losetup -d "$loop_dev"
        echo "Loop device detached"
    fi
}

cleanup_temp_inodes() {
    if [ -e "$temp_dir" ]; then
        rmdir "$temp_dir"
        echo "Temporal dir removed: $temp_dir"
    fi
    for f in "$img_file" "$key_file" "$key2_file"; do
        if [ -e "$f" ]; then
            rm -f "$f"
            echo "Temporal file removed: $f"
        fi
    done
}

partition_device() {
    parted -s "$1" mklabel gpt
    parted -s --align optimal "$1" mkpart testPartition 0% 100%
    # Search only block devices with major number 7 (loop devices)
    part_dev="$(lsblk "$1" -p -n -l -I 7 -o NAME | sed -n 2p)"
    echo "Device partition created: $(ls $part_dev)"
}

format_device() {
    mkfs.ext4 "$1"
    echo "Device filesystem created: $(ls $1)"
}

mount_filesystem() {
    mount "$1" "$2"
    echo "Filesystem mounted: $(ls -d $2)"
}

unmount_filesystem() {
    umount "$1"
    echo "Filesystem unmounted"
}

format_and_mount() {
    format_device "$1"
    mount_filesystem "$1" "$temp_dir"
}

write_test_file() {
    echo "$test_text" >> "$temp_dir/$test_file"
    echo "File created on mounted filesystem: $(ls $temp_dir/$test_file)"
}

cryptsetup_encrypt_and_map() {
    echo -n "$2" | cryptsetup --batch-mode luksFormat "$1"
    echo -n "$2" | cryptsetup --batch-mode luksOpen "$1" "$map_name"
    echo "Device encrypted and mapped: $(ls $map_dev)"
}

cryptsetup_unmount_and_close() {
    unmount_filesystem "$temp_dir"
    cryptsetup luksClose "$map_name"
    echo "Device unmapped"
}

cryptsetup_map_and_mount() {
    echo -n "$2" | cryptsetup luksOpen "$1" "$map_name"
    echo "Device mapped: $(ls $map_dev)"
    mount_filesystem "$map_dev" "$temp_dir"
}

cryptsetup_add_key() {
    cryptsetup --key-file "$2" luksAddKey "$1" "$3"
    echo "Second key added"
}

cryptsetup_remove_key() {
    cryptsetup luksRemoveKey "$1" "$2"
    echo "Main key removed"
}

pycryptsetup_exists() {
    if "$python3_bin" -c "import pycryptsetup" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

pycryptsetup_encrypt_and_map() {
    "$python3_bin" -c "import $python_test_mod as pycrypt; \
        pycrypt.encrypt_and_activate_device(\"$1\", \"$2\", \"$map_name\")"
    echo "Device encrypted and mapped: $(ls $map_dev)"
}

pycryptsetup_map() {
    "$python3_bin" -c "import $python_test_mod as pycrypt; \
        pycrypt.activate_device(\"$1\", \"$2\", \"$map_name\")"
    echo "Device mapped: $(ls $map_dev)"
}

pycryptsetup_unmount_and_close() {
    unmount_filesystem "$temp_dir"
    "$python3_bin" -c "import $python_test_mod as pycrypt; \
        pycrypt.close_device(\"$map_name\")"
    echo "Device unmapped"
}

pycryptsetup_map_and_mount() {
    pycryptsetup_map "$1" "$2"
    mount_filesystem "$map_dev" "$temp_dir"
}

pycryptsetup_add_passphrase() {
    "$python3_bin" -c "import $python_test_mod as pycrypt; \
        pycrypt.add_passphrase_to_device(\"$1\", \"$2\", \"$3\")"
    echo "Second key added"
}

pycryptsetup_remove_passphrase() {
    "$python3_bin" -c "import $python_test_mod as pycrypt; \
        pycrypt.remove_passphrase_from_device(\"$1\", \"$2\")"
    echo "Main key removed"
}

cryptsetup_simple_partition_encryption_with_LUKS() {
    [ -b "$loop_dev" ]
    partition_device "$loop_dev"

    [ -b "$part_dev" ]
    cryptsetup_encrypt_and_map "$part_dev" "$passphrase"

    [ -b "$map_dev" -a -d "$temp_dir" ]
    format_and_mount "$map_dev"
    write_test_file
    cryptsetup_unmount_and_close

    # Test the file system can be accessed correctly.
    cryptsetup_map_and_mount "$part_dev" "$passphrase"
    [ "$test_text" == "$(cat $temp_dir/$test_file)" ]

    # Add a second key slot and remove the first one.
    cryptsetup_add_key "$part_dev" "$key_file" "$key2_file"
    cryptsetup_remove_key "$part_dev" "$key_file"
    cryptsetup_unmount_and_close

    # Test the first key slot doesn't have access anymore.
    run cryptsetup --key-file "$key_file" luksOpen "$part_dev" "$map_name"
    [ "$output" == "No key available with this passphrase." ]

    # Test the second key slot still has access.
    cryptsetup_map_and_mount "$part_dev" "$passphrase2"
    [ "$test_text" == "$(cat $temp_dir/$test_file)" ]

    # If python exists and pycryptsetup is installed and can be loaded,
    # close the device and open it with pycryptsetup.
    if [ -f "$python3_bin" ] && pycryptsetup_exists; then
        echo "Pycryptsetup found, test opening the device with it"
        cryptsetup_unmount_and_close
        pycryptsetup_map_and_mount "$part_dev" "$passphrase2"
        [ "$test_text" == "$(cat $temp_dir/$test_file)" ]
    fi
}

pycryptsetup_simple_partition_encryption_with_LUKS() {
    if [ ! -f "$python3_bin" ]; then
        skip "this test needs python3 to run"
    fi
    [ -b "$loop_dev" ]
    partition_device "$loop_dev"

    [ -b "$part_dev" ]
    pycryptsetup_encrypt_and_map "$part_dev" "$passphrase"

    [ -b "$map_dev" -a -d "$temp_dir" ]
    format_and_mount "$map_dev"
    write_test_file

    pycryptsetup_unmount_and_close

    # Test the file system can be accessed correctly.
    pycryptsetup_map_and_mount "$part_dev" "$passphrase"
    [ "$test_text" == "$(cat $temp_dir/$test_file)" ]

    # Add a second key slot and remove the first one.
    pycryptsetup_add_passphrase "$part_dev" "$passphrase" "$passphrase2"
    pycryptsetup_remove_passphrase "$part_dev" "$passphrase"
    pycryptsetup_unmount_and_close

    # Test the first key slot doesn't have access anymore.
    run pycryptsetup_map "$part_dev" "$passphrase"
    [ "${lines[0]}" == "activate: -1" ]

    # Test the second key slot still has access.
    pycryptsetup_map_and_mount "$part_dev" "$passphrase2"
    [ "$test_text" == "$(cat $temp_dir/$test_file)" ]

    # Close the device and open it with cryptsetup.
    echo "Test opening the device with cryptsetup"
    pycryptsetup_unmount_and_close
    cryptsetup_map_and_mount "$part_dev" "$passphrase2"
    [ "$test_text" == "$(cat $temp_dir/$test_file)" ]
}

#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Run a command and check it produces nothing to stdout
Q() {
        local _r _o _v=""
        [ "$1" = "-v" ] && shift && _v="Unexpected output from $*"
        _o="$("$@")"
        _r=$?
        [ -z "$_o" ] && return $_r
        [ -n "$_v" ] && printf "%s\n" "$_v"
        printf "%s\n" "$_o"
        return 1
}

# When scanning, we ignore:
#
# - /proc, follows its own rules
# - /run/user/ is runtime generated and will get a gnome VFS mounted
#   which behaves its own way and not even root can recurse into it.
#
@test "STIG file permission test" {
	#01) 0920 /root should be 0750 or less
	Q find / -maxdepth 1 -type d -perm /0027 -name root -printf "GEN000920: %p is %m should be 0750 or less\n"
	Q find /usr/share/locale -type f -perm /0133 -printf "GEN001280: %p is %m should be 0644 or less\n"
	Q find /usr/share/man -type f -perm /0133 -printf "GEN001280: %p is %m should be 0644 or less\n"
	Q find /usr/share/package-licenses -type f -perm /0133 -printf "GEN001280: %p is %m should be 0644 or less\n"
	Q find /lib -type f -perm /0022 -printf "GEN001300: %p is %m should be 0755 or less\n"
	Q find /lib64 -type f -perm /0022 -printf "GEN001300: %p is %m should be 0755 or less\n"
	Q find /usr/lib -type f -perm /0022 -printf "GEN001300: %p is %m should be 0755 or less\n"
	Q find /usr/lib64 -type f -perm /0022 -printf "GEN001300: %p is %m should be 0755 or less\n"
	Q find /usr/lib32 -type f -perm /0022 -printf "GEN001300: %p is %m should be 0755 or less\n"

	if [ ! -h /bin ] ; then
		Q find /bin -type f -perm /0022 -printf "GEN001200: %p is %m should be 0755 or less\n"
		Q find /sbin -type f -perm /0022 -printf "GEN001200: %p is %m should be 0755 or less\n"
	fi
	Q find /usr/bin -type f -perm /0022 -printf "GEN001200: %p is %m should be 0755 or less\n"
	Q find /usr/sbin -type f -perm /0022 -printf "GEN001200: %p is %m should be 0755 or less\n"


	#08) 1220 system command dirs must be own by a system account
	if [ ! -h /bin ] ; then
		Q find /bin -type d \( ! -user root \) -printf "GEN001220: %p is user %u should be root\n"
		Q find /sbin -type d \( ! -user root \) -printf "GEN001220: %p is user %u should be root\n"
	fi
	Q find /usr/bin -type d \( ! -user root \) -printf "GEN001220: %p is user %u should be root\n"
	Q find /usr/sbin -type d \( ! -user root \) -printf "GEN001220: %p is user %u should be root\n"

	#09) 1240 system command dirs must be owned by a system group
	if [ ! -h /bin ] ; then
		Q find /bin -type d \( ! -group root \) -printf "GEN001220: %p is group %g should be root\n"
		Q find /sbin -type d \( ! -group root \) -printf "GEN001220: %p is group %g should be root\n"
	fi
	Q find /usr/bin -type d \( ! -group root \) -printf "GEN001220: %p is group %g should be root\n"
	Q find /usr/sbin -type d \( ! -group root \) -printf "GEN001220: %p is group %g should be root\n"

	#13) 2500 sticky bit must be on all world writable dirs
	Q find / \( -path /proc -o -path /run/user/\* \) -prune -o -type d \( -perm -0002 -a ! -perm -1000 \) -printf "GEN002500: %p is %m should be 1777\n"


	#14) 2520 all world writable dirs must be owned by system account
	Q find / \( -path /proc -o -path /run/user/\* \) -prune -o -type d \( -perm -0002 -a ! \( -user root -o -user gdm -o -user telemetry \) \) -printf "GEN002520: world writable %p is user %u should be root\n"


}

@test "No world writable directories (non-sticky)" {
        Q find / \( -path /proc -o -path /run/user/\* \) -prune -o -path /sys -prune -o -perm /o=w -type d ! -perm /1000 -print 2>/dev/null
}

@test "Files in /usr/bin are executable" {
        Q find /usr/bin -maxdepth 1 -type f ! -perm /o=x 2>/dev/null
}

@test "Files in /usr/lib64 are executable" {
        Q find /usr/lib64 -name '*so.*' -maxdepth 1 -type f ! -perm /o=x 2>/dev/null
}

@test "Files in /usr/lib32 are executable" {
        Q find /usr/lib32 -name '*so.*' -maxdepth 1 -type f ! -perm /o=x  2>/dev/null
}

@test "Content of /usr/bin is not world writable" {
        Q find /usr/bin -perm /o=w ! -type l 2>/dev/null
}

@test "Content of /usr/lib64 is not world writable" {
        Q find /usr/lib64 -perm /o=w ! -type l 2>/dev/null
}

@test "Non-executable stack security check" {
	bash find-execstack
}

@test "Only whitelisted suid files in /usr" {
	local whitelist=(
		/usr/bin/at
		/usr/bin/cgexec
		/usr/bin/chage
		/usr/bin/chfn
		/usr/bin/chsh
		/usr/bin/expiry
		/usr/bin/fusermount3
		/usr/bin/fusermount-glusterfs
		/usr/bin/gpasswd
		/usr/bin/mount.nfs
		/usr/bin/newgidmap
		/usr/bin/newgrp
		/usr/bin/newuidmap
		/usr/bin/passwd
		/usr/bin/ping
		/usr/bin/ping6
		/usr/bin/pkexec
		/usr/bin/spice-client-glib-usb-acl-helper
		/usr/bin/su
		/usr/bin/sudo
		/usr/bin/traceroute6
		/usr/bin/unix_chkpwd
		/usr/bin/Xorg
		/usr/libexec/dbus-daemon-launch-helper
		/usr/libexec/qemu-bridge-helper
		/usr/libexec/ssh-keysign
		/usr/lib/polkit-1/polkit-agent-helper-1
	)
	local flattened=`printf -- "-not -path %s " "${whitelist[@]}"`
	Q find /usr -perm /u=s ${flattened} 2> /dev/null
}

@test "Only whitelisted sgid files in /usr" {
	local whitelist=(
                /usr/bin/locate
	)
	local flattened=`printf -- "-not -path %s " "${whitelist[@]}"`
	Q find /usr -perm /g=s ${flattened} 2> /dev/null
}

#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

setup() {
	if ! systemctl is-active docker; then
		../../src/bat-kata-containers/set-up-docker-service.sh
	fi
	TMP_DIR=$(mktemp -d)
	pushd "$TMP_DIR"
}

teardown() {
	popd
	rm -rf "$TMP_DIR"
}

@test "Create minimal mix natively" {
	mixer init
	mixer build bundles --native
	mixer build update --native
}

@test "Create mix with local RPM in Docker container" {
	mixer init --local-rpms --no-default-bundles
	cat > local-bundles/chrome <<- EOF
	# [TITLE]: chrome
	# [DESCRIPTION]: Google Chrome browser
	# [STATUS]: Active
	# [CAPABILITIES]: Browse the internets
	# [MAINTAINER]: me@example.com
	google-chrome-stable
	EOF
	mixer bundle add os-core
	mixer bundle add os-core-update
	mixer bundle add kernel-kvm
	mixer bundle add chrome
	curl --retry 3 --retry-delay 10 --fail --silent --show-error --location --remote-name https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	mv google-chrome-stable_current_x86_64.rpm local-rpms/
	mixer add-rpms
	mixer build all
	[ -e update/www/10/Manifest.chrome ] && [ -s update/www/10/Manifest.chrome ]
	cat > release-image-config.json <<- EOF
	{
		"DestinationType" : "virtual",
		"PartitionLayout" : [ { "disk" : "release.img", "partition" : 1, "size" : "32M", "type" : "EFI" },
							{ "disk" : "release.img", "partition" : 2, "size" : "16M", "type" : "swap" },
							{ "disk" : "release.img", "partition" : 3, "size" : "10G", "type" : "linux" } ],
		"FilesystemTypes" : [ { "disk" : "release.img", "partition" : 1, "type" : "vfat" },
							{ "disk" : "release.img", "partition" : 2, "type" : "swap" },
							{ "disk" : "release.img", "partition" : 3, "type" : "ext4" } ],
		"PartitionMountPoints" : [ { "disk" : "release.img", "partition" : 1, "mount" : "/boot" },
							{ "disk" : "release.img", "partition" : 3, "mount" : "/" } ],
		"Version": "latest",
		"Bundles": ["kernel-kvm", "os-core", "os-core-update", "chrome"]
	}
	EOF
	mixer build image --native
	[ -e release.img ] && [ -s release.img ]
}

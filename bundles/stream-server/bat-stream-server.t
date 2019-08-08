#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Video/Audio streaming
# ---------------------
#
# Author      :   Mario Alfredo Carrillo Arevalo
#
# Requirements:   bundle stream-server
#

SRC="../../src/bat-stream-server/"

#
# * Check installes plugins for basic tasks
#
@test "Inspect plugins" {
	bash $SRC/gstests.sh --inspect-plugins
}

#
# * Verify video/audio sources
#
@test "Verify video/audio src/sink" {
	bash $SRC/gstests.sh --check-srcsink
}

#
# * Dump a frame to a file using an image format (JPEG/PNG)
#
@test "Image encoding" {
	bash $SRC/gstests.sh --img-encoding
}

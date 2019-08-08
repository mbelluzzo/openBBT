#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*
#

# liberation-fonts - basic test
# -----------------
#
# Author      :   Athenas Jimenez
# Requirements:   desktop-assets
#


@test "bat-liberation-fonts: LiberationMono" {
[ -f /usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf ]
[ -f /usr/share/fonts/truetype/liberation/LiberationMono-BoldItalic.ttf ]
[ -f /usr/share/fonts/truetype/liberation/LiberationMono-Italic.ttf ]
[ -f /usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf ]
}

@test "bat-liberation-fonts: LiberationSans" {
[ -f /usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf ]
[ -f /usr/share/fonts/truetype/liberation/LiberationSans-BoldItalic.ttf ]
[ -f /usr/share/fonts/truetype/liberation/LiberationSans-Italic.ttf ]
[ -f /usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf ]
}

@test "bat-liberation-fonts: LiberationSerif" {
[ -f /usr/share/fonts/truetype/liberation/LiberationSerif-Bold.ttf ]
[ -f /usr/share/fonts/truetype/liberation/LiberationSerif-BoldItalic.ttf ]
[ -f /usr/share/fonts/truetype/liberation/LiberationSerif-Italic.ttf ]
[ -f /usr/share/fonts/truetype/liberation/LiberationSerif-Regular.ttf ]
}


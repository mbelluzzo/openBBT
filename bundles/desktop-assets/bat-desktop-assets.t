#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

#
# Author      :   Victor Rodriguez
#
# Requirements:   bundle desktop-assets

@test "adwaita-icon-theme" {
[ -f /usr/share/icons/Adwaita/16x16/actions/action-unavailable-symbolic.symbolic.png ]
}

@test "arc-theme" {
[ -f /usr/share/themes/Arc-Dark/gnome-shell/common-assets/dash/dash-left.svg ]
}

@test "clear-font" {
[ -f /usr/share/defaults/fonts/conf.d/42-clear.conf ]
}

@test "clr-wallpapers" {
[ -f /usr/share/backgrounds/clearlinux/logo_2560x1440.png ]
}

@test "faba-icon-theme" {
[ -f /usr/share/icons/Faba/16x16/actions/add-files-to-archive.svg ]
}

@test "gnome-backgrounds" {
[ -n "$(ls -A /usr/share/backgrounds/gnome/)" ]
}

@test "gnome-icon-theme" {
[ -f /usr/share/icons/gnome/16x16/actions/add.png ]
}

@test "gnome-themes-standard" {
[ -f /usr/share/icons/HighContrast/16x16/actions/action-unavailable.png ]
}

@test "hicolor-icon-theme" {
[ -f /usr/share/icons/hicolor/index.theme ]
}

@test "moka-icon-theme" {
[ -f /usr/share/icons/Moka/16x16/actions/exit.png ]
}

@test "powerline-fonts" {
[ -f /usr/share/fonts/X11/TTF/AnonymicePowerline.ttf ]
}

@test "xcursor-themes" {
[ -f /usr/share/icons/handhelds/cursors/xterm ]
}


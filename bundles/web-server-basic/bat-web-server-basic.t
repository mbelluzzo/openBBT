#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Web Server - basic test
# -----------------
#
# Author      :   Salvador Fuentes
#
# Requirements:   bundle web-server-basic
#

load "../../utils/bbtlib"

HTTP_ROOT="/var/www/html"

@test "copy and update httpd configuration" {
    cp -r /usr/share/defaults/httpd/ /etc/httpd/
    #Add a non existing path
    echo "IncludeOptional /etc/fakepath/" >> /etc/httpd/httpd.conf
}


@test "initializing httpd service" {
    systemctl_check_start httpd.service
    mkdir -p $HTTP_ROOT/test
    echo "New Page works!" > $HTTP_ROOT/test/index.html
}

#
# * verify default page is loaded
#
@test "default page is loaded" {
    timeout_test "curl -svL --noproxy '*' 127.0.0.1 2>&1| grep -q '200 OK'" 5
}

# * new content is loadead
# ..* Add a directory and a new html file to the default http directory
# ..* verify that new html page is loaded
@test "New content is loadead" {
    timeout_test "curl -svL --noproxy '*' 127.0.0.1/test 2>&1| grep -q '200 OK'" 5
}

@test "stoping httpd service" {
    systemctl_check_stop httpd.service
    rm -rf $HTTP_ROOT/test
    rm -rf /etc/httpd/
}

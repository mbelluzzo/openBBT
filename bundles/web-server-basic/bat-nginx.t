#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Web Server with NGINX- basic test
# -----------------
#
# Author      :   Josue David Hernandez Gutierrez
#
# Requirements:   bundle web-server-basic
#

load "../../utils/bbtlib"

NGINX_BASE="/etc/nginx"
NGINX_CONF="$NGINX_BASE/conf.d"
NGINX_SHARE="/usr/share/nginx"
HTTP_ROOT="/var/www/html"

setup() {
    mkdir -p $NGINX_CONF
    cp $NGINX_SHARE/conf/nginx.conf.example $NGINX_BASE/nginx.conf
    cp $NGINX_SHARE/conf/server.conf.example $NGINX_CONF/server.conf
    sed -i "s|root   html|root   ${HTTP_ROOT}|g" $NGINX_CONF/server.conf
}

teardown() {
    rm -rf $NGINX_BASE
}

@test "initializing services" {
    systemctl_check_start nginx.service
    mkdir -p $HTTP_ROOT/test
    echo "New Page works!" > $HTTP_ROOT/test/index.html
}

#
# * verify default page is loaded
#
@test "default page is loaded by nginx" {
    timeout_test "curl -svL --noproxy '*' 127.0.0.1 2>&1| grep -q '200 OK'" 5
}

# * new content is loadead
# ..* Add a directory and a new html file to the default http directory
# ..* verify that new html page is loaded
@test "New content is loadead by nginx" {
    timeout_test "curl -svL --noproxy '*' 127.0.0.1/test 2>&1| grep -q '200 OK'" 5
}

@test "stoping nginx services" {
    systemctl_check_stop nginx.service
    rm -rf $HTTP_ROOT
}

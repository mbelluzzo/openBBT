#!/bin/bash
mkdir -p /tmp/bundles
pushd /tmp/bundles
curl -OL https://raw.githubusercontent.com/clearlinux/clr-bundles/master/bundles/desktop-locales
sed -i '/^$/d;/^#/d' desktop-locales
popd

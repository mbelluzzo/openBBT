#!/bin/bash
set -e
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/00-kata.conf <<- EOF
[Journal]
RateLimitInterval=0s
RateLimitBurst=0
EOF
systemctl restart systemd-journald

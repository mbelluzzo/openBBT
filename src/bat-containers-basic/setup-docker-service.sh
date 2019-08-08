#!/bin/bash

https_proxy=${https_proxy:-$http_proxy}
mkdir /etc/systemd/system/docker.service.d -p
cat <<EOT | tee /etc/systemd/system/docker.service.d/proxy.conf
[Service]
Environment=HTTP_PROXY=$http_proxy
Environment=HTTPS_PROXY=$https_proxy
EOT
if [ -n $no_proxy ]; then
    echo "Environment=NO_PROXY=$no_proxy" >> \
    /etc/systemd/system/docker.service.d/proxy.conf
fi

systemctl daemon-reload
systemctl restart docker

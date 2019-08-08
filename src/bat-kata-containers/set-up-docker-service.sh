#!/bin/bash
set -e
if env | grep -q '_proxy'; then
	mkdir -p "$HOME"/.docker
	cat > "$HOME"/.docker/config.json <<- EOF
	{
		"proxies":
		{
			"default":
			{
				"httpProxy": "$http_proxy",
				"httpsProxy": "$https_proxy",
				"noProxy": "$no_proxy"
			}
		}
	}
	EOF
	mkdir -p /etc/systemd/system/docker.service.d
	cat > /etc/systemd/system/docker.service.d/00-kata.conf <<- EOF
	[Service]
	Environment=HTTP_PROXY=$http_proxy
	Environment=HTTPS_PROXY=$https_proxy
	Environment=NO_PROXY=$no_proxy
	EOF
	systemctl daemon-reload
fi
systemctl restart docker

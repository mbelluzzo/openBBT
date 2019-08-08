#!/usr/bin/env bats

SRC="../../src/bat-containers-basic/"

setup() { 
	source $SRC/test.common
	conf_dir="/etc/systemd/system/docker.service.d/"
	conf_runtime_file="${conf_dir}/runtime.conf"
	systemctl daemon-reload
}

teardown(){
	systemctl status docker.service
	rm -f "${conf_runtime_file}"
	systemctl daemon-reload
	systemctl restart docker.service
}

@test "default is kata-runtime" {
	if [ ! -c /dev/kvm ]; then
		skip "KVM is not enabled"
	fi
	systemctl restart docker.service
	docker info | grep  -P '^Default Runtime: kata-runtime$'
	docker info | grep -P '^Runtimes: ' | grep 'kata-runtime'
}
@test "default is runc if no kvm" {
	if [ -c /dev/kvm ]; then
		skip "KVM is enabled"
	fi
	systemctl restart docker.service
	docker info | grep  -P '^Default Runtime: runc$'
	docker info | grep -P '^Runtimes: ' | grep -v 'kata-runtime'
}

@test "dockerd command specify runtime" {
	systemctl stop docker.service

	change_default_runtime
	systemctl daemon-reload
	systemctl start docker.service
	docker info | grep -P '^Runtimes: ' | grep 'runc2'
	docker info | grep  -P '^Default Runtime: runc2$'
}


function change_default_runtime(){
	mkdir -p "${conf_dir}"
	cat > "${conf_runtime_file}" << EOT  
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --add-runtime runc2=runc --default-runtime=runc2
EOT
}

#!/usr/bin/env bats

conf_dir="/etc/systemd/system/docker.service.d/"
conf_runtime_file="${conf_dir}/runtime.conf"

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

@test "default is runc" {
	[ -f /usr/bin/kata-runtime ] && skip "has kata containers"
	systemctl restart docker.service
	docker info | grep  -P '^Default Runtime: runc$'
	docker info | grep -P '^Runtimes: runc$'
}

@test "default is kata-runtime if  kata containers and kvm" {
	[ -f /usr/bin/kata-runtime ] || skip "no kata containers"
	[ -c /dev/kvm ] || skip "no kvm"
	systemctl restart docker.service
	docker info | grep  -P '^Default Runtime: kata'
	docker info | grep -P '^Runtimes:' | grep 'kata'
}

@test "dockerd command specify runtime" {
	systemctl stop docker.service

	change_default_runtime
	systemctl daemon-reload
	systemctl start docker.service
	docker info | grep  -P '^Default Runtime: runc2$'
	rm "${conf_runtime_file}"
	systemctl daemon-reload
	systemctl start docker.service
}


function change_default_runtime(){
	mkdir -p "${conf_dir}"
	cat > "${conf_runtime_file}" << EOT  
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --add-runtime runc2=runc --default-runtime=runc2

EOT
}

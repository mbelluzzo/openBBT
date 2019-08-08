#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# DOCKER - basic test
# --------------
#
# Author      :   Gabriela Cervantes
#
# Requirements:   bundle containers-basic
#

SRC="../../src/bat-containers-basic/"

setup() {
	source $SRC/test.common
        systemctl is-active docker || bash $SRC/setup-docker-service.sh
	cleanDockerPs
	}

@test "Checking for issues with certificates" {
	$DOCKER_EXE pull busybox
	$DOCKER_EXE rmi busybox
	}

@test "Commit a container" {
	$DOCKER_EXE run -i --name container1 busybox /bin/sh -c "echo hello"
	$DOCKER_EXE commit -m "test_commit" container1 container/test-container
	$DOCKER_EXE rmi container/test-container
	}

@test "Commit a container with new configurations" {
	$DOCKER_EXE run -i --name container2 busybox /bin/sh -c "echo hello"
	$DOCKER_EXE inspect -f "{{ .Config.Env }}" container2
	$DOCKER_EXE commit --change "ENV DEBUG true" container2 test/container-test
	$DOCKER_EXE rmi test/container-test
	}

@test "Create a container" {
	$DOCKER_EXE create -ti --name container1 busybox true
	$DOCKER_EXE ps -a | grep "container1"
	}

@test "Create network" {
	$DOCKER_EXE network ls
	$DOCKER_EXE network create -d bridge my-bridge-network
	$DOCKER_EXE network ls | grep "my-bridge-network"
	$DOCKER_EXE network rm my-bridge-network
	}

@test "Export a container" {
	$DOCKER_EXE run -ti -d --name container1 busybox
	$DOCKER_EXE export container1 > latest.tar
	if [ ! -f latest.tar ]; then
		exit 1
	fi
	rm -rf latest.tar
	}

@test "Container info" {
	$DOCKER_EXE run -itd --name container1 busybox
	$DOCKER_EXE info| grep "Containers: 1"
	}

@test "Inspect a container ip address" {
	$DOCKER_EXE run -ti -d --name container1 busybox
	$DOCKER_EXE inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container1
	}

@test "Inspect a container with json format" {
	$DOCKER_EXE run -ti -d --name container2 busybox
	$DOCKER_EXE inspect --format='{{json .Config}}' container2
	}

@test "Inspect a container to get instance's log path" {
	$DOCKER_EXE run -ti -d --name container3 busybox
	$DOCKER_EXE inspect --format='{{.LogPath}}' container3
	}

@test "Kill a container" {
	$DOCKER_EXE run -d -ti --name container1 busybox sh
	$DOCKER_EXE kill container1
	}

@test "Load container" {
	$DOCKER_EXE run -itd --name=container1 busybox
	$DOCKER_EXE commit container1 mynewimage
	$DOCKER_EXE save mynewimage> /tmp/mynewimage.tar
	$DOCKER_EXE load < /tmp/mynewimage.tar
	$DOCKER_EXE images | grep "mynewimage"
	$DOCKER_EXE rmi mynewimage
	}

@test "Retrieve logs from container" {
	$DOCKER_EXE run -d -ti --name container1 ubuntu /bin/bash -c "echo 'hello world' > file; cat file"
	$DOCKER_EXE logs container1
	}

@test "HostName is passed to the container" {
	hostName=clr-container
	$DOCKER_EXE run -h $hostName -i ubuntu hostname | grep $hostName
	}

@test "Verify connectivity between 2 containers" {
	contName='pingTest'
	$DOCKER_EXE run -tid --name "$contName" ubuntu bash
	ip_addr=$($DOCKER_EXE inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$contName")
	$DOCKER_EXE run -i debian ping -c 1 "$ip_addr" | grep -q '1 received'
	}

@test "Port a container" {
	$DOCKER_EXE run -tid -p 8080:8080 --name container1 busybox 
	$DOCKER_EXE port container1 8080/tcp
	}

@test "Restart a container" {
	$DOCKER_EXE run -ti -d --name container1 busybox
	$DOCKER_EXE ps -a | grep "Up"
	$DOCKER_EXE stop container1
	$DOCKER_EXE ps -a | grep "Exited"
	$DOCKER_EXE restart container1
	$DOCKER_EXE ps -a | grep "Up"
	}

@test "Tag a container" {
	$DOCKER_EXE run -i busybox true
	$DOCKER_EXE tag busybox container1
	$DOCKER_EXE images | grep "container1"
	$DOCKER_EXE rmi container1
	}

@test "Volume inspect container" {
	$DOCKER_EXE volume create --name container1
	$DOCKER_EXE volume ls | grep "container1"
	$DOCKER_EXE volume inspect --format '{{ .Mountpoint }}' container1
	$DOCKER_EXE volume rm container1
	}

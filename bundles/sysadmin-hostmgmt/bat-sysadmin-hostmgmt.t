#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*

# Sysadmin-mgmt - basic test
# -----------------
#
# Author      :   Josue David Hernandez Gutierrez
#
# Requirements:   bundle sysadmin-mgmt
#

SRC="../../src/bat-sysadmin-hostmgmt/"
REPO_NAME="samplerepo"

setup() {
    pushd $SRC
    if [ "$(git config --global user.email)" == "" ]; then
        git config --global user.email "test@clearlinux.com"
        git config --global user.name "test clear linux"
    fi
}

#
# * Testing git creating a repo and cloning it
#
@test "testing git creating a repo and cloning it" {
    git init --bare ${REPO_NAME}.git
    git clone ${REPO_NAME}.git
    cd ${REPO_NAME}
    echo "some text" > file_one
    git add .
    git commit -a -m "some text"
    git log | grep "some text"
    git push origin master
    git log | grep -E "commit [a-z0-9]+" | awk '{print $2}' | \
        grep -f ../${REPO_NAME}.git/refs/heads/master
    cd -; rm -rf ${REPO_NAME} ${REPO_NAME}.git
}

#
# * Testing pssh executing an echo
#
@test "testing pssh executing an echo" {
    skip
    pssh --host "127.0.0.1 127.0.0.1" echo "hello pssh"
}

#
# * Testing Yaml library for python
#
@test "Testing Yaml library for python" {
    cd "PyYAML"
    ./load_monster.py -m monster.yaml | grep "Giant Spider"
    cd -
}

#
# * Testing Jinja2 on Python
#
@test "Testing Jinja2 on Python" {
    cd "Jinja2"
    [ $(./show_user.py -t template/template.html | grep -E "Jhon[1-5]*" | \
        wc -l) -eq 6 ]
    [ $(./show_user.py -t template/template.json | grep -E "Jhon[1-5]*" | \
        wc -l) -eq 6 ]
    cd -
}

#
# * Testing ansible playbooks
#
@test "Testing ansible playbooks" {
    cd playbook
    ansible-playbook -i hosts --connection=local file_creator.yml
    [ -e file.txt ]
    rm file.txt
}

#
# * Testing swupd in ansible
#
@test "Testing swupd in ansible" {
    grep -q '^VERSION_ID=1$' /usr/lib/os-release && skip
    cd swupd-playbooks
    ansible-playbook -i hosts --connection=local swupd.yml -e "format=staging" | grep "ok=5"
}

#
# * Testing ansible facts in Clear Linux
#
@test "Testing ansible facts in Clear Linux" {
    cd clr-playbooks
    ansible-playbook -i hosts --connection=local clear.yml | grep "ok=4" | grep "changed=3"
}

#
# * Testing System Variables
#
@test "Testing ansible system variables" {
    source /usr/lib/os-release
    ansible -m setup localhost | grep "ansible_distribution_release" | grep $ID
    ansible -m setup localhost | grep "ansible_distribution_major_version" | grep $VERSION_ID
    ansible -m setup localhost | grep "ansible_distribution_version" | grep $VERSION_ID
}

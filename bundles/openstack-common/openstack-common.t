#!/usr/bin/env bats
# *-*- Mode: sh; c-basic-offset: 8; indent-tabs-mode: nil -*-*


@test "erlang-basic" {

    echo "-module(hello)." > hello.erl
    echo "-export([hello_world/0])." >> hello.erl
    echo "hello_world() ->" >> hello.erl
    echo "io:fwrite('hello, world')." >> hello.erl
    erl -compile hello
    erl -noshell -s hello hello_world -s init stop
    rm -rf hello.erl hello.beam
}

@test "rabbit-basic" {

    systemctl start epmd.service
    systemctl start rabbitmq-server
    cp /var/lib/rabbitmq/.erlang.cookie $HOME
    rabbitmqctl status
    systemctl stop epmd.service
    systemctl stop rabbitmq-server
}

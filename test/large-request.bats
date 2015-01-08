#!/usr/bin/env bats

load test_helper

setup() {
  $BIN --port "$PORT" &
  pid=$!
}

teardown() {
  kill -9 $pid
  sleep 0
}

name="ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd.ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc.bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

@test "dig largest A record question" {
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
}

@test "dig largest AAAA record question" {
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name AAAA +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
}

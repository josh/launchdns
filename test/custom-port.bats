#!/usr/bin/env bats

load test_helper

PORT="65454"

setup() {
  $BIN --port "$PORT" &
  pid=$!
}

teardown() {
  kill -9 $pid
  sleep 0
}

@test "dig A record" {
  name="test"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +edns=0 +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"test.			600	IN	A	127.0.0.1"* ]]
}

@test "dig AAAA record" {
  name="test"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name AAAA +edns=0 +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"test.			600	IN	AAAA	::1"* ]]
}

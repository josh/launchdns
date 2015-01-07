#!/usr/bin/env bats

load test_helper

setup() {
  $BIN --port "$PORT" &
  pid=$!
}

teardown() {
  kill $pid
  sleep 0
}

@test "dig default A record" {
  name="test"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"test.			600	IN	A	127.0.0.1"* ]]
}

@test "dig default AAAA record" {
  name="test"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name AAAA +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"test.			600	IN	AAAA	::1"* ]]
}

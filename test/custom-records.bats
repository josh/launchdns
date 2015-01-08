#!/usr/bin/env bats

load test_helper

A="8.8.8.8"
AAAA="2001:4860:4860::8888"

setup() {
  $BIN --port "$PORT" --a "$A" --aaaa "$AAAA" &
  pid=$!
}

teardown() {
  kill -9 $pid
  sleep 0
}

@test "dig custom A record" {
  name="test"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"test.			600	IN	A	$A"* ]]
}

@test "dig custom AAAA record" {
  name="test"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name AAAA +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"test.			600	IN	AAAA	$AAAA"* ]]
}

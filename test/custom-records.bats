#!/usr/bin/env bats

load test_helper

A="8.8.8.8"
AAAA="2001:4860:4860::8888"

setup() {
  $BIN --port "$PORT" --a "$A" --aaaa "$AAAA" &
  pid=$!
}

teardown() {
  kill $pid
  sleep 0
}

@test "dig custom A record" {
  name="test"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noall +answer +comments
  [ "$status" -eq 0 ]
  echo "$output" | grep "status: NOERROR,"
  echo "$output" | grep "^test.\t\t\t600\tIN\tA\t$A"
}

@test "dig custom AAAA record" {
  name="test"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name AAAA +noall +answer +comments
  [ "$status" -eq 0 ]
  echo "$output" | grep "status: NOERROR,"
  echo "$output" | grep "^test.\t\t\t600\tIN\tAAAA\t$AAAA"
}

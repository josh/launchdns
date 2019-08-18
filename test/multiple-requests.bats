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

@test "dig multiple requests (plain DNS and plain EDNS)" {
  name="test"

  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noedns +noall +answer +comments
  [ "$status" -eq 0 ]
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noedns +noall +answer +comments
  [ "$status" -eq 0 ]

  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +edns=0 +noall +answer +comments
  [ "$status" -eq 0 ]

  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noedns +noall +answer +comments
  [ "$status" -eq 0 ]

  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +edns=0 +noall +answer +comments
  [ "$status" -eq 0 ]

  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +edns=0 +noall +answer +comments
  [ "$status" -eq 0 ]
}

#!/usr/bin/env bats

load test_helper

setup() {
  $BIN --port="$PORT" &
  pid=$!
}

teardown() {
  kill $pid
  sleep 0
}

@test "dig dev A record" {
  name="dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"dev.			600	IN	A	127.0.0.1"* ]]
}

@test "dig foo.dev A record" {
  name="foo.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"foo.dev.		600	IN	A	127.0.0.1"* ]]
}

@test "dig bar.dev A record" {
  name="bar.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"bar.dev.		600	IN	A	127.0.0.1"* ]]
}

@test "dig foo.bar.dev A record" {
  name="foo.bar.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"foo.bar.dev.		600	IN	A	127.0.0.1"* ]]
}

@test "dig dev AAAA record" {
  name="dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name AAAA +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"dev.			600	IN	AAAA	::1"* ]]
}

@test "dig foo.dev AAAA record" {
  name="foo.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name AAAA +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"foo.dev.		600	IN	AAAA	::1"* ]]
}

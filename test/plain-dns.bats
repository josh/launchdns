#!/usr/bin/env bats

load test_helper

setup() {
  $BIN --port="$PORT" &
  pid=$!
}

teardown() {
  kill -9 $pid
  sleep 0
}

# subdomain tests

@test "dig foo.dev A record (plain DNS)" {
  name="foo.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noedns +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"foo.dev.		600	IN	A	127.0.0.1"* ]]
}

@test "dig foo.bar.dev A record (plain DNS)" {
  name="foo.bar.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noedns +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"foo.bar.dev.		600	IN	A	127.0.0.1"* ]]
}

@test "dig foo.dev AAAA record (plain DNS)" {
  name="foo.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name AAAA +noedns +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NOERROR,"* ]]
  [[ "$output" == *"foo.dev.		600	IN	AAAA	::1"* ]]
}

# NXDOMAIN tests

@test "dig MX record (plain DNS)" {
  name="dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name MX +noedns +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NXDOMAIN,"* ]]
}

@test "dig subdomain MX record (plain DNS)" {
  name="foo.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name MX +noedns +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NXDOMAIN,"* ]]
}

@test "dig subdomain CNAME record (plain DNS)" {
  name="foo.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name CNAME +noedns +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NXDOMAIN,"* ]]
}

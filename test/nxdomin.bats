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

@test "dig MX record" {
  name="dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name MX +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NXDOMAIN,"* ]]
}

@test "dig subdomain MX record" {
  name="foo.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name MX +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NXDOMAIN,"* ]]
}

@test "dig CNAME record" {
  name="dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name CNAME +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NXDOMAIN,"* ]]
}

@test "dig subdomain CNAME record" {
  name="foo.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name CNAME +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NXDOMAIN,"* ]]
}

@test "dig TXT record" {
  name="dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name TXT +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NXDOMAIN,"* ]]
}

@test "dig subdomain TXT record" {
  name="foo.dev"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name TXT +noall +answer +comments
  [ "$status" -eq 0 ]
  [[ "$output" == *"status: NXDOMAIN,"* ]]
}

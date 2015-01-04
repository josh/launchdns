#!/usr/bin/env bats

load test_helper

plist=$(launch_plist "test.socket.plist")

setup() {
  if [ -n "$LAUNCHD" ]; then
    launchctl load "$plist"
  fi
}

teardown() {
  if [ -n "$LAUNCHD" ]; then
    launchctl unload "$plist"
  fi
}

@test "dig A record" {
  if [ -z "$LAUNCHD" ]; then
    skip "no launchd"
  fi

  name="test"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name A +noall +answer +comments
  [ "$status" -eq 0 ]
  echo "$output" | grep "status: NOERROR,"
  echo "$output" | grep "^test.\t\t\t600\tIN\tA\t127.0.0.1"
}

@test "dig AAAA record" {
  if [ -z "$LAUNCHD" ]; then
    skip "no launchd"
  fi

  name="test"
  run dig +tries=1 +time=1 -p $PORT @127.0.0.1 $name AAAA +noall +answer +comments
  [ "$status" -eq 0 ]
  echo "$output" | grep "status: NOERROR,"
  echo "$output" | grep "^test.\t\t\t600\tIN\tAAAA\t::1"
}

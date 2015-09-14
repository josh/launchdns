#!/usr/bin/env bats

load test_helper

@test "prints version" {
  run "$BIN" --version
  echo "${lines[0]}" | grep "launchdns 1."
  [ "$status" -eq 0 ]
}

@test "prints version with shorthand" {
  run "$BIN" -v
  echo "${lines[0]}" | grep "launchdns 1."
  [ "$status" -eq 0 ]
}

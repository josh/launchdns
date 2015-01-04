#!/usr/bin/env bats

load test_helper

@test "timeout in 1 second" {
  run $BIN --port "$PORT" --timeout 1
  [ "$status" -eq 0 ]
}

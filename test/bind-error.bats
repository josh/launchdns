#!/usr/bin/env bats

load test_helper

name=$(basename "$BIN")

PORT="65455"

setup() {
  $BIN --port "$PORT" &
  pid=$!
}

teardown() {
  kill -9 $pid
  sleep 0
}

@test "bind address already in use" {
  run "$BIN" --port "$PORT"
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Could not open socket on $PORT: Address already in use" ]
}

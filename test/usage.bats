#!/usr/bin/env bats

load test_helper

name=$(basename "$BIN")

@test "invalid option prints error" {
  run "$BIN" --invalid
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "$name: unrecognized option \`--invalid'" ]
}

@test "missing port argument prints error" {
  run "$BIN" --port
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "$name: option \`--port' requires an argument" ]
}

@test "missing a argument prints error" {
  run "$BIN" --a
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "$name: option \`--a' requires an argument" ]
}

@test "missing aaaa argument prints error" {
  run "$BIN" --aaaa
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "$name: option \`--aaaa' requires an argument" ]
}

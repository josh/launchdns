expand_path() {
  { cd "$(dirname "$1")" 2>/dev/null
    local dirname="$PWD"
    cd "$OLDPWD"
    echo "$dirname/$(basename "$1")"
  } || echo "$1"
}

render() {
  eval "echo \"$(cat $1)\""
}

launch_plist() {
  plist="$BATS_TMPDIR/$1"
  render "$BATS_TEST_DIRNAME/LaunchAgents/$1" > "$plist"
  echo "$plist"
}

LAUNCHD=$(which launchctl || echo)
BIN=$(expand_path "$BATS_TEST_DIRNAME/../bin/dns")
PORT="65353"

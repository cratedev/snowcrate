{pkgs}:
pkgs.writeShellScriptBin "dotfile-state-restore" ''
  #!/usr/bin/env bash
  set -euo pipefail

  repo="git@github.com:cratedev/dotfile-state.git"
  host="matt@$HOSTNAME"

  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT

  ${pkgs.git}/bin/git clone --quiet --depth 1 "$repo" "$tmpdir"

  src="$tmpdir/$host"
  if [ ! -d "$src" ]; then
    echo "dotfile-state: no saved state found for $host"
    exit 0
  fi

  cp -r "$src/." "$HOME/"
  echo "dotfile-state: restored $host"
''

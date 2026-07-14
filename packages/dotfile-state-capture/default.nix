{pkgs}:
pkgs.writeShellScriptBin "dotfile-state-capture" ''
  #!/usr/bin/env bash
  set -euo pipefail

  repo="git@github.com:cratedev/dotfile-state.git"
  host="matt@$HOSTNAME"
  paths=(
    ".config/DankMaterialShell"
    ".local/state/DankMaterialShell"
    ".config/vesktop"
    ".config/obsidian"
    ".config/YouTube Music Desktop App"
  )

  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT

  ${pkgs.git}/bin/git clone --quiet "$repo" "$tmpdir"

  dest="$tmpdir/$host"
  mkdir -p "$dest"

  for path in "''${paths[@]}"; do
    src="$HOME/$path"
    if [ -e "$src" ]; then
      mkdir -p "$dest/$(dirname "$path")"
      rm -rf "$dest/$path"
      cp -r "$src" "$dest/$path"
    fi
  done

  cd "$tmpdir"
  ${pkgs.git}/bin/git add -A

  if ${pkgs.git}/bin/git diff --cached --quiet; then
    echo "dotfile-state: nothing changed for $host"
    exit 0
  fi

  ${pkgs.git}/bin/git commit --quiet -m "Capture $host dotfile state $(date -Iseconds)"
  ${pkgs.git}/bin/git push --quiet
  echo "dotfile-state: captured and pushed $host"
''

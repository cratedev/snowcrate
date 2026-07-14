{
  pkgs,
  capturedPaths,
}:
pkgs.writeShellScriptBin "dotfile-state-check" ''
  #!/usr/bin/env bash
  set -euo pipefail

  captured=(
    ${pkgs.lib.concatMapStringsSep "\n    " (p: ''"${p}"'') capturedPaths}
  )

  is_captured() {
    local p="$1" cp
    for cp in "''${captured[@]}"; do
      [[ "$p" == "$cp" || "$p" == "$cp"/* ]] && return 0
    done
    return 1
  }

  mounted=$(${pkgs.util-linux}/bin/findmnt -rno TARGET | grep "^$HOME/" || true)

  is_persisted() {
    local full="$HOME/$1" m
    while IFS= read -r m; do
      [[ -n "$m" && ( "$full" == "$m" || "$full" == "$m"/* ) ]] && return 0
    done <<< "$mounted"
    return 1
  }

  not_persisted=()
  persisted_uncaptured=()

  for base in ".config" ".local/share" ".local/state"; do
    dir="$HOME/$base"
    [ -d "$dir" ] || continue
    while IFS= read -r -d $'\0' entry; do
      rel="''${entry#"$HOME"/}"
      [ -L "$entry" ] && continue
      if is_persisted "$rel"; then
        is_captured "$rel" || persisted_uncaptured+=("$rel")
      else
        not_persisted+=("$rel")
      fi
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0)
  done

  echo "dotfile-state-check: scanning ~/.config, ~/.local/share, ~/.local/state"
  echo

  if [ ''${#not_persisted[@]} -gt 0 ]; then
    echo "NOT PERSISTED -- will be wiped on next reboot:"
    printf '  %s\n' "''${not_persisted[@]}"
    echo
  fi

  if [ ''${#persisted_uncaptured[@]} -gt 0 ]; then
    echo "PERSISTED but not in dotfile-state capture -- lost on a fresh deploy:"
    printf '  %s\n' "''${persisted_uncaptured[@]}"
    echo
  fi

  if [ ''${#not_persisted[@]} -eq 0 ] && [ ''${#persisted_uncaptured[@]} -eq 0 ]; then
    echo "Nothing undeclared found."
  fi
''

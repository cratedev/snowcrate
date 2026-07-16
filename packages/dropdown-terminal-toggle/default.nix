{pkgs}:
pkgs.writeShellScriptBin "dropdown-terminal-toggle" ''
  #!/usr/bin/env bash

  if [ -z "$NIRI_SOCKET" ]; then
    export NIRI_SOCKET="$XDG_RUNTIME_DIR/niri/niri-socket"
  fi

  DROPDOWN_ID=$(${pkgs.niri}/bin/niri msg -j windows | ${pkgs.jq}/bin/jq -r '.[] | select(.title == "dropdown-terminal") | .id')

  if [ -z "$DROPDOWN_ID" ]; then
    ${pkgs.ghostty}/bin/ghostty --title=dropdown-terminal -e ${pkgs.zellij}/bin/zellij attach --create dropdown &
  else
    IS_FOCUSED=$(${pkgs.niri}/bin/niri msg -j windows | ${pkgs.jq}/bin/jq -r ".[] | select(.id == $DROPDOWN_ID) | .is_focused")

    if [ "$IS_FOCUSED" = "true" ]; then
      ${pkgs.niri}/bin/niri msg action close-window
    else
      ${pkgs.niri}/bin/niri msg action focus-window --id "$DROPDOWN_ID"
    fi
  fi
''

{pkgs}:
pkgs.writeShellScriptBin "dropdown-terminal-toggle" ''
  #!/usr/bin/env bash

  # Ensure NIRI_SOCKET is set
  if [ -z "$NIRI_SOCKET" ]; then
    export NIRI_SOCKET="$XDG_RUNTIME_DIR/niri/niri-socket"
  fi

  # Get the dropdown terminal window ID if it exists
  DROPDOWN_ID=$(${pkgs.niri}/bin/niri msg -j windows | ${pkgs.jq}/bin/jq -r '.[] | select(.title == "dropdown-terminal") | .id')

  if [ -z "$DROPDOWN_ID" ]; then
    # Dropdown doesn't exist - spawn it
    ${pkgs.ghostty}/bin/ghostty --title=dropdown-terminal -e ${pkgs.zellij}/bin/zellij attach --create dropdown &
  else
    # Dropdown exists - check if it's focused
    IS_FOCUSED=$(${pkgs.niri}/bin/niri msg -j windows | ${pkgs.jq}/bin/jq -r ".[] | select(.id == $DROPDOWN_ID) | .is_focused")

    if [ "$IS_FOCUSED" = "true" ]; then
      # Dropdown is focused - close it
      ${pkgs.niri}/bin/niri msg action close-window
    else
      # Dropdown exists but not focused - focus it
      ${pkgs.niri}/bin/niri msg action focus-window --id "$DROPDOWN_ID"
    fi
  fi
''

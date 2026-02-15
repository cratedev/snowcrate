{
  lib,
  pkgs,
  namespace,
  ...
}:
pkgs.writeShellScriptBin "dropdown-terminal-toggle" ''
  #!/usr/bin/env bash

  # Get the currently focused window title
  FOCUSED=$(${pkgs.niri}/bin/niri msg -j windows | ${pkgs.jq}/bin/jq -r '.[] | select(.is_focused == true) | .title')

  if [ "$FOCUSED" = "dropdown-terminal" ]; then
    # Dropdown is focused - switch to the last window
    ${pkgs.niri}/bin/niri msg action focus-window-down
  elif ${pkgs.niri}/bin/niri msg -j windows | ${pkgs.jq}/bin/jq -e '.[] | select(.title == "dropdown-terminal")' > /dev/null; then
    # Dropdown exists but not focused - focus it
    ${pkgs.niri}/bin/niri msg action focus-window --title "dropdown-terminal"
  else
    # Dropdown doesn't exist - spawn it
    ${pkgs.ghostty}/bin/ghostty --title=dropdown-terminal -e ${pkgs.zellij}/bin/zellij attach --create dropdown &
  fi
''

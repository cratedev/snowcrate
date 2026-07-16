{pkgs}:
pkgs.writeShellScriptBin "snowcrate-status" ''
  #!/usr/bin/env bash
  set -euo pipefail

  cat /etc/snowcrate-info 2>/dev/null || echo "host/rev info unknown"

  profile="$(${pkgs.coreutils}/bin/readlink -f /nix/var/nix/profiles/system)"
  gen="$(${pkgs.coreutils}/bin/basename "$profile" | ${pkgs.gnused}/bin/sed -E 's/^system-([0-9]+)-link$/\1/')"
  echo "generation: $gen"
  echo "built: $(${pkgs.coreutils}/bin/stat -c %y "$profile")"
''

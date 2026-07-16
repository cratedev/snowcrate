{pkgs}:
pkgs.writeShellScriptBin "deploy-test-vm" ''
  #!/usr/bin/env bash
  set -euo pipefail

  state_dir="$HOME/.local/state/deploy-test-vm"
  installer_result="$state_dir/installer-result"
  disk_img="$state_dir/disk.qcow2"
  dummy_img="$state_dir/dummy-nvme0.qcow2"
  ovmf_vars="$state_dir/OVMF_VARS.fd"
  pidfile="$state_dir/qemu.pid"
  portfile="$state_dir/ssh_port"
  hostfile="$state_dir/current-host"
  console_log="$state_dir/console.log"
  disk_size="40G"
  ram_mb=8192
  cpus=2

  ovmf_code_template="${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"
  ovmf_vars_template="${pkgs.OVMF.fd}/FV/OVMF_VARS.fd"

  usage() {
    echo "Usage: deploy-test-vm <start <crate-laptop|crate-desktop>|stop|status|reboot|verify-persistence>" >&2
    echo "  start <host>          boot a fresh VM for testing deploy against" >&2
    echo "  reboot                power-cycle the running VM, keeping its disk" >&2
    echo "  verify-persistence    after a real deploy, reboot and confirm" >&2
    echo "                        environment.persistence actually survives" >&2
    echo "                        while everything else is wiped" >&2
    exit 1
  }

  is_running() {
    [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null
  }

  cmd_status() {
    if is_running; then
      echo "VM running (pid $(cat "$pidfile")), SSH forwarded to localhost:$(cat "$portfile")"
    else
      echo "VM not running"
    fi
  }

  cmd_stop() {
    if is_running; then
      echo "Stopping VM (pid $(cat "$pidfile"))..."
      kill "$(cat "$pidfile")"
      rm -f "$pidfile" "$portfile" "$hostfile"
    else
      echo "VM not running"
    fi
  }

  build_disk_args() {
    local host="$1"
    extra_disk_args=()
    if [ "$host" = "crate-laptop" ]; then
      # Second virtual NVMe controller, so the real disk lands on
      # /dev/nvme1n1, matching crate-laptop's disk-config.nix.
      extra_disk_args=(
        -drive file="$dummy_img",if=none,id=nvme0,format=qcow2
        -device nvme,drive=nvme0,serial=deadbeef00
        -drive file="$disk_img",if=none,id=nvme1,format=qcow2
        -device nvme,drive=nvme1,serial=deadbeef01,bootindex=1
      )
    else
      extra_disk_args=(
        -drive file="$disk_img",if=none,id=nvme0,format=qcow2
        -device nvme,drive=nvme0,serial=deadbeef00,bootindex=1
      )
    fi
  }

  # bootindex is re-evaluated on every boot: the disk (bootindex=1)
  # boots once nixos-anywhere installs a bootloader there, otherwise
  # firmware falls through to the installer ISO (bootindex=2, only
  # attached when iso_path is set).
  launch_qemu() {
    local host="$1"
    build_disk_args "$host"

    local iso_args=()
    if [ -n "''${iso_path:-}" ]; then
      iso_args=(
        -drive file="$iso_path",if=none,id=installcd,media=cdrom,readonly=on
        -device ide-cd,drive=installcd,bootindex=2
      )
    fi

    ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -enable-kvm \
      -m "$ram_mb" \
      -smp "$cpus" \
      -cpu host \
      -drive if=pflash,format=raw,readonly=on,file="$ovmf_code_template" \
      -drive if=pflash,format=raw,file="$ovmf_vars" \
      "''${extra_disk_args[@]}" \
      "''${iso_args[@]}" \
      -boot menu=off \
      -netdev user,id=net0,hostfwd=tcp::''${ssh_port}-:22 \
      -device virtio-net-pci,netdev=net0 \
      -display none \
      -serial file:"$console_log" \
      -monitor none \
      -pidfile "$pidfile" \
      -daemonize
  }

  wait_for_ssh() {
    echo "Waiting for SSH to become reachable on localhost:$ssh_port..."
    local waited=0
    until ${pkgs.netcat}/bin/nc -z localhost "$ssh_port" 2>/dev/null; do
      sleep 5
      waited=$((waited + 5))
      if [ "$waited" -ge 300 ]; then
        echo "Timed out waiting for SSH after 5 minutes. Check boot output at $console_log, or 'deploy-test-vm status', then stop and retry." >&2
        exit 1
      fi
    done
  }

  cmd_start() {
    local host="''${1:-}"
    case "$host" in
      crate-laptop | crate-desktop) ;;
      *) usage ;;
    esac

    if is_running; then
      echo "VM already running -- run 'deploy-test-vm stop' first" >&2
      exit 1
    fi

    mkdir -p "$state_dir"
    echo "$host" > "$hostfile"

    # Pick a free ephemeral port for SSH forwarding.
    local ssh_port
    ssh_port="$(${pkgs.python3}/bin/python3 -c 'import socket; s = socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')"
    echo "$ssh_port" > "$portfile"

    # Build a custom installer ISO with matt's SSH key baked into the
    # "nixos" user, since the stock ISO has no password set for it.
    echo "Building custom installer ISO with SSH key baked in (cached by Nix after first build)..."
    ${pkgs.nix}/bin/nix build "$HOME/snowcrate#nixosConfigurations.deploy-test-installer.config.system.build.isoImage" \
      --out-link "$installer_result" \
      --extra-experimental-features 'nix-command flakes'
    local iso_path
    iso_path="$(find "$installer_result/iso" -name '*.iso' | head -n1)"
    if [ -z "$iso_path" ]; then
      echo "Failed to locate built installer ISO in $installer_result/iso" >&2
      exit 1
    fi

    echo "Creating fresh $disk_size disk image (sparse, so real usage stays low)..."
    rm -f "$disk_img"
    ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$disk_img" "$disk_size" >/dev/null

    # Nix store files are read-only; QEMU needs to write to this one.
    cp "$ovmf_vars_template" "$ovmf_vars"
    chmod u+w "$ovmf_vars"

    if [ "$host" = "crate-laptop" ]; then
      rm -f "$dummy_img"
      ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$dummy_img" 64M >/dev/null
    fi

    echo "Starting VM for $host (RAM: ''${ram_mb}MB, CPUs: $cpus, disk: $disk_size)..."
    launch_qemu "$host"
    wait_for_ssh

    echo ""
    echo "VM ready. Test the deploy script against it with:"
    echo ""
    echo "  deploy $host --target ssh://nixos@localhost:$ssh_port"
    echo ""
    echo "Stop the VM afterward with: deploy-test-vm stop"
  }

  cmd_reboot() {
    if ! is_running; then
      echo "VM not running" >&2
      exit 1
    fi
    local host
    host="$(cat "$hostfile" 2>/dev/null || true)"
    if [ -z "$host" ]; then
      echo "Don't know which host this VM was started for -- run 'deploy-test-vm start <host>' first" >&2
      exit 1
    fi
    local ssh_port
    ssh_port="$(cat "$portfile")"
    local iso_path=""

    echo "Stopping VM (disk preserved)..."
    kill "$(cat "$pidfile")"
    local waited=0
    while kill -0 "$(cat "$pidfile")" 2>/dev/null; do
      sleep 1
      waited=$((waited + 1))
      if [ "$waited" -ge 30 ]; then
        echo "VM didn't stop after 30s" >&2
        exit 1
      fi
    done
    rm -f "$pidfile"

    echo "Restarting VM from its existing disk (simulating a power cycle)..."
    launch_qemu "$host"
    wait_for_ssh
    echo "VM back up on localhost:$ssh_port"
  }

  cmd_verify_persistence() {
    if ! is_running; then
      echo "VM not running -- start it and run a real deploy against it first" >&2
      exit 1
    fi

    local ssh_port ssh_opts marker
    ssh_port="$(cat "$portfile")"
    ssh_opts=(-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p "$ssh_port")
    marker="persist-check-$(date +%s)"

    echo "Writing a marker under ~/documents (persisted) and one directly under \$HOME (not persisted)..."
    ${pkgs.openssh}/bin/ssh "''${ssh_opts[@]}" matt@localhost \
      "mkdir -p ~/documents && echo $marker > ~/documents/.persistence-test && echo $marker > ~/.persistence-test-should-vanish"

    cmd_reboot

    ssh_port="$(cat "$portfile")"
    ssh_opts=(-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p "$ssh_port")

    local persisted vanished
    persisted="$(${pkgs.openssh}/bin/ssh "''${ssh_opts[@]}" matt@localhost "cat ~/documents/.persistence-test 2>/dev/null || true")"
    vanished="$(${pkgs.openssh}/bin/ssh "''${ssh_opts[@]}" matt@localhost "cat ~/.persistence-test-should-vanish 2>/dev/null || true")"
    ${pkgs.openssh}/bin/ssh "''${ssh_opts[@]}" matt@localhost "rm -f ~/documents/.persistence-test" || true

    echo ""
    local ok=1
    if [ "$persisted" = "$marker" ]; then
      echo "PASS: ~/documents survived the reboot, as declared in environment.persistence."
    else
      echo "FAIL: ~/documents did not survive the reboot -- check environment.persistence for this host."
      ok=0
    fi

    if [ -z "$vanished" ]; then
      echo "PASS: an undeclared path under \$HOME was correctly wiped on reboot."
    else
      echo "FAIL: an undeclared path under \$HOME survived the reboot -- the rollback service may not be running."
      ok=0
    fi

    [ "$ok" -eq 1 ]
  }

  case "''${1:-}" in
    start)
      shift
      cmd_start "''${1:-}"
      ;;
    stop) cmd_stop ;;
    status) cmd_status ;;
    reboot) cmd_reboot ;;
    verify-persistence) cmd_verify_persistence ;;
    *) usage ;;
  esac
''

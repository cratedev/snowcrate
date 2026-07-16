{pkgs}:
pkgs.writeShellScriptBin "deploy-test-vm" ''
  #!/usr/bin/env bash
  set -euo pipefail

  state_dir="$HOME/.local/state/deploy-test-vm"
  iso_path="$state_dir/nixos-installer.iso"
  disk_img="$state_dir/disk.qcow2"
  dummy_img="$state_dir/dummy-nvme0.qcow2"
  ovmf_vars="$state_dir/OVMF_VARS.fd"
  pidfile="$state_dir/qemu.pid"
  ssh_port=2222
  disk_size="40G"
  ram_mb=8192
  cpus=2

  ovmf_code_template="${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"
  ovmf_vars_template="${pkgs.OVMF.fd}/FV/OVMF_VARS.fd"

  usage() {
    echo "Usage: deploy-test-vm <start <crate-laptop|crate-desktop>|stop|status>" >&2
    exit 1
  }

  is_running() {
    [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null
  }

  cmd_status() {
    if is_running; then
      echo "VM running (pid $(cat "$pidfile")), SSH forwarded to localhost:$ssh_port"
    else
      echo "VM not running"
    fi
  }

  cmd_stop() {
    if is_running; then
      echo "Stopping VM (pid $(cat "$pidfile"))..."
      kill "$(cat "$pidfile")"
      rm -f "$pidfile"
    else
      echo "VM not running"
    fi
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

    if [ ! -f "$iso_path" ]; then
      echo "Downloading NixOS minimal installer ISO (cached at $iso_path for future runs)..."
      ${pkgs.curl}/bin/curl -L -o "$iso_path" \
        "https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso"
    fi

    echo "Creating fresh $disk_size disk image (sparse, so real usage stays low)..."
    rm -f "$disk_img"
    ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$disk_img" "$disk_size" >/dev/null

    cp "$ovmf_vars_template" "$ovmf_vars"

    local extra_disk_args=()
    if [ "$host" = "crate-laptop" ]; then
      # crate-laptop's disk-config.nix hardcodes /dev/nvme1n1 (the
      # second NVMe controller on that real hardware). Add a tiny
      # throwaway first NVMe device so the real test disk lands on
      # nvme1n1 too, letting the unmodified disk-config.nix apply as-is
      # instead of needing a test-only variant.
      echo "Setting up dual-NVMe topology to match crate-laptop's /dev/nvme1n1..."
      rm -f "$dummy_img"
      ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$dummy_img" 64M >/dev/null
      extra_disk_args=(
        -drive file="$dummy_img",if=none,id=nvme0,format=qcow2
        -device nvme,drive=nvme0,serial=deadbeef00
        -drive file="$disk_img",if=none,id=nvme1,format=qcow2
        -device nvme,drive=nvme1,serial=deadbeef01
      )
    else
      extra_disk_args=(
        -drive file="$disk_img",if=none,id=nvme0,format=qcow2
        -device nvme,drive=nvme0,serial=deadbeef00
      )
    fi

    echo "Starting VM for $host (RAM: ''${ram_mb}MB, CPUs: $cpus, disk: $disk_size)..."
    ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -enable-kvm \
      -m "$ram_mb" \
      -smp "$cpus" \
      -cpu host \
      -drive if=pflash,format=raw,readonly=on,file="$ovmf_code_template" \
      -drive if=pflash,format=raw,file="$ovmf_vars" \
      "''${extra_disk_args[@]}" \
      -cdrom "$iso_path" \
      -boot order=d \
      -netdev user,id=net0,hostfwd=tcp::''${ssh_port}-:22 \
      -device virtio-net-pci,netdev=net0 \
      -nographic \
      -pidfile "$pidfile" \
      -daemonize

    echo "Waiting for SSH to become reachable on localhost:$ssh_port (installer ISO takes a bit to boot)..."
    local waited=0
    until ${pkgs.netcat}/bin/nc -z localhost "$ssh_port" 2>/dev/null; do
      sleep 5
      waited=$((waited + 5))
      if [ "$waited" -ge 300 ]; then
        echo "Timed out waiting for SSH after 5 minutes. Check 'deploy-test-vm status', or stop and retry." >&2
        exit 1
      fi
    done

    echo ""
    echo "VM ready. Test the deploy script against it with:"
    echo ""
    echo "  ./scripts/deploy $host --target ssh://nixos@localhost:$ssh_port"
    echo ""
    echo "Stop the VM afterward with: deploy-test-vm stop"
  }

  case "''${1:-}" in
    start)
      shift
      cmd_start "''${1:-}"
      ;;
    stop) cmd_stop ;;
    status) cmd_status ;;
    *) usage ;;
  esac
''

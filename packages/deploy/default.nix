{
  pkgs,
  inputs,
}:
pkgs.writeShellScriptBin "deploy" ''
  #!/usr/bin/env bash
  set -euo pipefail

  usage() {
    echo "Usage: deploy <crate-laptop|crate-desktop|crate-server|crate-server-vm> [--target <ssh-target>]" >&2
    echo "  --target overrides the default host address, e.g. for testing" >&2
    echo "  against a local VM: --target ssh://nixos@localhost:2222" >&2
    exit 1
  }

  HOST="''${1:-}"
  [[ -z "$HOST" ]] && usage
  shift

  TARGET_OVERRIDE=""
  if [[ "''${1:-}" == "--target" ]]; then
    TARGET_OVERRIDE="''${2:-}"
    [[ -z "$TARGET_OVERRIDE" ]] && usage
  fi

  case "$HOST" in
    crate-laptop)
      TARGET_HOST="nixos@10.0.0.155"
      ;;
    crate-desktop)
      TARGET_HOST="nixos@10.0.0.50"
      ;;
    crate-server)
      TARGET_HOST="nixos@10.0.0.55"
      ;;
    crate-server-vm)
      # Test-only flake output (see packages/deploy-test-vm) -- always
      # used with --target against a local VM, never a real address.
      TARGET_HOST="nixos@unused-vm-target"
      ;;
    *)
      usage
      ;;
  esac

  EXTRA_SSH_PORT_ARGS=()
  TEST_PORT=""
  if [[ -n "$TARGET_OVERRIDE" ]]; then
    TARGET_HOST="$TARGET_OVERRIDE"

    # Strip the port out of ssh://user@host:port and pass it via
    # nixos-anywhere's -p/--post-kexec-ssh-port instead: its disko step
    # uses ssh-ng://, which doesn't parse a trailing :port off the host.
    if [[ "$TARGET_HOST" =~ ^ssh://([^@]+)@([^:/]+):([0-9]+)$ ]]; then
      TARGET_HOST="''${BASH_REMATCH[1]}@''${BASH_REMATCH[2]}"
      TEST_PORT="''${BASH_REMATCH[3]}"
      EXTRA_SSH_PORT_ARGS=(-p "$TEST_PORT" --post-kexec-ssh-port "$TEST_PORT")
    fi
  fi

  FLAKE_TARGET="$HOME/snowcrate/.#''${HOST}"
  SECRETS_DIR="$HOME/nix-secrets/secrets"
  SECRETS_REPO="git@github.com:cratedev/nix-secrets"

  # tmpfs-backed: key material never touches persistent storage.
  TEMP_KEYS_DIR="$(mktemp -d /dev/shm/deploy-keys.XXXXXX)"
  PERSIST_DIR="$TEMP_KEYS_DIR/persist/etc/ssh"

  # Colors for output
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m' # No Color

  log() {
    echo -e "''${GREEN}[INFO]''${NC} $1"
  }

  warn() {
    echo -e "''${YELLOW}[WARN]''${NC} $1"
  }

  error() {
    echo -e "''${RED}[ERROR]''${NC} $1" >&2
    exit 1
  }

  ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
      log "Creating directory: $dir"
      mkdir -p "$dir"
    fi
  }

  clone_secrets() {
    local secrets_parent="$HOME/nix-secrets"

    if [[ ! -d "$SECRETS_DIR" ]]; then
      log "Secrets directory not found. Checking parent directory..."
      log "Cloning from $SECRETS_REPO..."
      if ! ${pkgs.git}/bin/git clone "$SECRETS_REPO" "$secrets_parent"; then
        error "Failed to clone secrets repository. Check SSH access to GitHub."
      fi
      log "Secrets repository cloned successfully!"
    else
      warn "Secrets directory already exists: $SECRETS_DIR"
    fi
  }

  main() {
    log "Starting NixOS deployment script for $HOST..."

    clone_secrets

    log "Changing to secrets directory: $SECRETS_DIR"
    cd "$SECRETS_DIR" || error "Failed to cd to $SECRETS_DIR"

    ensure_dir "$PERSIST_DIR"

    log "Decrypting SSH host key..."
    if ! ${inputs.agenix.packages.x86_64-linux.default}/bin/agenix -d recovery/ssh_host_ed25519_key.age > "$PERSIST_DIR/ssh_host_ed25519_key"; then
      error "Failed to decrypt SSH host key"
    fi

    if ! ${inputs.agenix.packages.x86_64-linux.default}/bin/agenix -d recovery/ssh_host_ed25519_key.age > "$TEMP_KEYS_DIR/persist/deployment_key"; then
      error "Failed to decrypt deployment key"
    fi

    chmod 600 "$PERSIST_DIR/ssh_host_ed25519_key"
    chmod 600 "$TEMP_KEYS_DIR/persist/deployment_key"
    log "Keys extracted successfully"

    log "Starting deployment to $TARGET_HOST..."
    log "Flake target: $FLAKE_TARGET"
    log "Extra files: $TEMP_KEYS_DIR"

    if ${pkgs.nix}/bin/nix run github:nix-community/nixos-anywhere \
      -- --flake "$FLAKE_TARGET" \
      --target-host "$TARGET_HOST" \
      "''${EXTRA_SSH_PORT_ARGS[@]}" \
      --extra-files "$TEMP_KEYS_DIR"; then
      log "Deployment completed successfully!"
      log ""
      if [[ -n "$TEST_PORT" ]]; then
        log "SSH into the freshly installed system with:"
        log "  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $TEST_PORT matt@localhost"
      else
        log "SSH into $HOST with:"
        log "  ssh matt@''${TARGET_HOST#*@}"
      fi
    else
      error "Deployment failed"
    fi
  }

  # Removes decrypted key material on exit, success or failure.
  cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
      warn "Script failed with exit code $exit_code"
    fi
    rm -rf "$TEMP_KEYS_DIR"
  }

  trap cleanup EXIT

  main
''

set shell := ["fish", "-c"]
flake_path := justfile_directory()
hostname := `hostname`
home_manager_output := "matt@${hostname}"

utils_nu := absolute_path("utils.nu")

default:
    @just --list

# Pulls latest master before any rebuild, so a flake-lock-update PR
# merged since your last pull gets picked up automatically. Skips the
# pull if there are uncommitted changes (e.g. a local `nix flake
# update` you haven't committed yet) rather than failing outright --
# this is a convenience, not something that should block real work.
_sync:
    #!/usr/bin/env fish
    cd {{flake_path}}
    if git diff --quiet; and git diff --cached --quiet
        git pull
    else
        echo "Skipping git pull -- uncommitted changes present."
    end

# Builds locally on crate-desktop. Elsewhere, builds remotely on
# crate-desktop over Tailscale if it answers, otherwise builds locally.
[group('nix')]
switch: _sync
    #!/usr/bin/env fish
    set build_host_args
    if test "{{hostname}}" != "crate-desktop"; and ssh -o ConnectTimeout=3 -o BatchMode=yes matt@10.0.0.50 true 2>/dev/null
        set build_host_args --build-host matt@10.0.0.50
    end
    nh os switch --hostname {{hostname}} {{flake_path}} $build_host_args -- --max-jobs auto --cores 0 --no-write-lock-file

# Flake Update
[group('nix')]
update: _sync
    nh os switch  --hostname {{hostname}} --update {{flake_path}}

# Same build-host logic as switch, but tests the config instead of
# making it the boot default.
[group('nix')]
test: _sync
    #!/usr/bin/env fish
    set build_host_args
    if test "{{hostname}}" != "crate-desktop"; and ssh -o ConnectTimeout=3 -o BatchMode=yes matt@10.0.0.50 true 2>/dev/null
        set build_host_args --build-host matt@10.0.0.50
    end
    nh os test --hostname {{hostname}} {{flake_path}} $build_host_args -- --max-jobs auto --cores 0 --no-write-lock-file

# Update specific input
# Usage: just upp nixpkgs
[group('nix')]
upp input:
    nix flake update {{input}}

# Restore persisted-but-not-declared app config (DMS, vesktop, etc.) from
# github.com/cratedev/dotfile-state. Run after a fresh deploy.
[group('nix')]
restore-dotfiles:
    dotfile-state-restore

# Capture persisted-but-not-declared app config and push it to
# github.com/cratedev/dotfile-state. Runs automatically weekly too
# (see dendritic/aspects/tools/dotfile-state.nix); this is for an
# on-demand checkpoint.
[group('nix')]
capture-dotfiles:
    dotfile-state-capture

# Scan ~/.config, ~/.local/share, ~/.local/state for app config that's
# either not persisted at all (wiped next reboot) or persisted but not
# covered by dotfile-state-capture (lost on a fresh deploy).
[group('nix')]
check-dotfiles:
    dotfile-state-check

# Test
[group('nix')]
ft: _sync
    nh os test --hostname {{hostname}} {{flake_path}} -- --no-write-lock-file
# Collect Garbage
[group('nix')]
ncg:
    nix-collect-garbage --delete-old ; sudo nix-collect-garbage -d ; sudo /run/current-system/bin/switch-to-configuration boot

[group('nix')]
cleanup:
    nh clean all

# Clean
[group('nix')]
clean:
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 3d
# Upgrade
[group('nix')]
upd:
    nh os switch -u {{flake_path}} ; nh os switch --hostname {{hostname}} {{flake_path}}

[group('nix')]
eval:
    nix-instantiate --eval --json --strict | jq
# Nix Repl flake:nixpkgs
[group('nix')]
repl:
    nix repl -f flake:nixpkgs

# format the nix files in this repo
[group('nix')]
fmt:
    nix fmt

# Show all the auto gc roots in the nix store
[group('nix')]
gcroot:
    ls -al /nix/var/nix/gcroots/auto/

# Verify all store entries
[group('nix')]
verify-store:
    nix store verify --all


[group('nix')]
repair-store *paths:
    nix store repair {{paths}}

# Usage: `./result/bin/run-*-vm`
# may need to set initialHashedPassword first
[group('nix')]
vm:
    sudo nixos-rebuild build-vm

# Start a fresh throwaway QEMU VM and test the deploy script against it
# (see packages/deploy-test-vm). Prints the deploy command to run next
# once the VM is ready.
# Usage: just test-deploy crate-laptop
[group('nix')]
test-deploy host:
    deploy-test-vm start {{host}}

[group('nix')]
test-deploy-status:
    deploy-test-vm status

[group('nix')]
test-deploy-stop:
    deploy-test-vm stop


system-info:
     "This is an {{arch()}} machine"

running:
    ps | where status == Running

help:
    help commands | explore


# =================================================
#
# Other useful commands
#
# =================================================

[group('common')]
path:
   $env.PATH | split row ":"

[group('common')]
trace-access app *args:
  strace -f -t -e trace=file {{app}} {{args}} | complete | $in.stderr | lines | find -v -r "(/nix/store|/newroot|/proc)" | parse --regex '"(/.+)"' | sort | uniq

[linux]
[group('common')]
penvof pid:
  sudo cat $"/proc/($pid)/environ" | tr '\0' '\n'

# Remove all reflog entries and prune unreachable objects
[group('git')]
ggc:
  git reflog expire --expire-unreachable=now --all
  git gc --prune=now

# Amend the last commit without changing the commit message
[group('git')]
game:
  git commit --amend -a --no-edit

[group('git')]
push:
    git push -u origin main

# Delete all failed pods
[group('k8s')]
del-failed:
  kubectl delete pod --all-namespaces --field-selector="status.phase==Failed"

[linux]
[group('services')]
list-inactive:
  systemctl list-units -all --state=inactive

[linux]
[group('services')]
list-failed:
  systemctl list-units -all --state=failed

[linux]
[group('services')]
list-systemd:
  systemctl list-units systemd-*

# List journal
[linux]
[group('services')]
jctl:
  ^jctl = "journalctl -p 5 -xb";

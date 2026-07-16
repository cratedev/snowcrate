# snowcrate

My NixOS configuration, covering three machines: crate-desktop, crate-laptop, and crate-server (the last one still a work in progress, not deployed). Single user throughout (matt).

## Layout

This is a flake-parts flake using the dendritic pattern: every `.nix` file under `dendritic/` is picked up automatically by `import-tree` and contributes to a `flake.modules.<class>.<name>` option, where class is `nixos` or `homeManager`. There's no central list of modules to keep in sync by hand; adding a file is enough to make it available.

Within `dendritic/`, the structure is:

- `aspects/` - one concern per file (a program, a service, a piece of hardware config), grouped loosely into subdirectories by topic. Each aspect defines a NixOS module, a home-manager module, or both, under the same name.
- `roles/` - bundles of aspects. `role-base` is the shared foundation almost everything imports; `role-desktop`, `role-laptop`, and `role-server` build on it with whatever's specific to that kind of machine.
- `hosts/` - one file per machine, each declaring a `flake.nixosConfigurations.<name>` output directly. This is where a role gets attached to an actual host along with its hardware and disk config.

Outside `dendritic/`:

- `machines/` - hardware scan output, disk layout (disko), and agenix secret wiring, one directory per host.
- `packages/` - standalone tools this repo builds, mostly small shell scripts wrapped with `writeShellScriptBin` (deploy tooling, dotfile-state backup, etc).
- `overlays/` - the handful of package overrides that don't fit anywhere else.

To add a new piece of config: drop a file under the right `aspects/` subdirectory, name the module something sensible, and import it from whichever role(s) should have it. To add a host: a new file under `machines/`, a new file under `dendritic/hosts/`, and a role to build it from.

## Secrets

Actual secrets never live in this repo. They're encrypted with agenix and kept in a separate private repo, `nix-secrets`, referenced as a flake input. `machines/agenix.nix` wires up the per-host secrets (SSH host and user keys, a couple of service env files); the per-host `machines/<host>/agenix.nix` files are one-line wrappers around it.

Because `nix-secrets` is a flake input, evaluating this flake at all - even just `nix flake check` - requires fetching it, which means SSH access to that repo. Locally that's whatever key your machine already has trusted there. In CI it's a dedicated read-only deploy key, stored as the `NIX_SECRETS_DEPLOY_KEY` repository secret.

## Deploying

`deploy <host>` (a packaged tool, not a bare script) clones `nix-secrets` if needed, decrypts what nixos-anywhere needs for a fresh install, and runs the install against the host's real IP. It also accepts `--target <ssh-target>` to point at something other than the real machine.

`deploy-test-vm` exists so that doesn't have to mean testing against real hardware. It boots a throwaway QEMU VM matching a given host's disk layout closely enough that the real, unmodified disk-config.nix applies as-is, builds a custom installer ISO with your SSH key baked in so `deploy` can reach it non-interactively, and wipes its disk on every `start` so a test never gets to lean on state left over from a previous run.

```
just test-deploy crate-laptop
deploy crate-laptop --target ssh://nixos@localhost:<port>   # port is printed by the previous command
```

`deploy-test-vm verify-persistence` goes a step further: after a real deploy to the test VM, it writes a marker under a path that's declared persistent and another under one that isn't, power-cycles the VM (reusing its disk, not wiping it), and checks that the declared path survived while the other one got wiped by the rollback-on-boot service. It's checking that the persistence mechanism itself actually works, not just that it's configured for everything you care about - `just check-dotfiles` handles that second question separately.

## Staying in sync

`switch`, `test`, `update`, and their remote-build variants all pull the latest `master` before doing anything else, so a flake-lock-update PR that got merged since you last touched the repo is picked up automatically instead of silently sitting stale. There's also a systemd timer (`git-sync-check`, on crate-desktop and crate-laptop) that checks periodically and sends a desktop notification if the local checkout has fallen behind, independent of whether you're about to run a rebuild.

`snowcrate-status` prints which git revision and which NixOS generation a machine is actually running, for when you want to check rather than assume.

## CI

Two workflows. `check` builds crate-desktop's and crate-laptop's full system closures on every push to master and every PR, plus a `statix`/`deadnix` pass over the Nix files - crate-server is excluded since it isn't deployment-ready yet. `update-flake-lock` bumps flake inputs weekly and opens a PR; it doesn't auto-merge, so master never moves without a deliberate merge, and by the time you do merge it, `check` has already told you whether it builds.

## Rebuilding from scratch

What's needed: this repo, the `nix-secrets` repo, and the SSH keys that let you into both. From there, `deploy <host>` against real hardware runs disko and nixos-install from nothing. Host SSH keys and the user's SSH keys are recovered via agenix from `nix-secrets`; everything else is either declared here or covered by `dotfile-state-restore` for the handful of things (DMS settings, a couple of app configs) that are persisted but not declared in Nix.

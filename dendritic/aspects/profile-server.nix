{self, ...}: {
  # On the old branch, modules/home/profiles/server had a copy-paste bug:
  # its config set `${namespace}.profiles.server.enable = true;` (itself,
  # a no-op) instead of `profiles.base.enable = true;` like its desktop/
  # laptop siblings -- so the server's home profile never actually turned
  # anything on. Fixed here by construction: there's no separate option to
  # typo, just an import list.
  flake.modules.homeManager.profile-server = {
    imports = [self.modules.homeManager.profile-base];
  };
}

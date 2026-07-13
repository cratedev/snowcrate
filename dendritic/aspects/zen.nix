{inputs, ...}: {
  # DankMaterialShell theming for Zen (the home.activation symlink script on
  # the old branch) is dropped here since it was never actually turned on
  # for crate-laptop (enableDankMaterialShell was never set true) -- this
  # only ports what's actually active.
  flake.modules.homeManager.zen = {...}: {
    home.packages = [inputs.zen-browser.packages.x86_64-linux.default];
  };
}

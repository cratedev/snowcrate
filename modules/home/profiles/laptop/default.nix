{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  options.${namespace}.profiles.laptop = {
    enable = mkBoolOpt false "Enable laptop profile";
  };

  config = mkIf config.${namespace}.profiles.laptop.enable {
    ${namespace}.profiles.base.enable = true;
  };
}

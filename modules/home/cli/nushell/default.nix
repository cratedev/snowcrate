{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.nushell;
in {
  options.${namespace}.cli.nushell = with types; {
    enable = mkBoolOpt false "Enable/disable nushell";
  };

  config = mkIf cfg.enable {
    programs = {
      nushell = {
        enable = true;
        extraConfig = ''
           def ns [] {
          	nix-search-tv print | fzf --preview="nix-search-tv preview {}" --scheme=history
          }
          			 $env.machine = (uname | get nodename | str trim)
          	 let carapace_completer = {|spans|
          		carapace $spans.0 nushell ...$spans | from json
          			 }
          			 $env.config = {
          				show_banner: false,
          				completions: {
          				case_sensitive: false # case-sensitive completions
          				quick: true    # set to false to prevent auto-selecting completions
          				partial: true    # set to false to prevent partial filling of the prompt
          				algorithm: "fuzzy"    # prefix or fuzzy
          				external: {
          				# set to false to prevent nushell looking into $env.PATH to find more suggestions
          						enable: true
          				# set to lower can improve completion performance at the cost of omitting some options
          						max_results: 100
          						completer: $carapace_completer # check 'carapace_completer'
          					}
          				}
          			 }
          			 $env.PATH = ($env.PATH |
          			 split row (char esep) |
          			 append /usr/bin/env
          			 )
        '';
        shellAliases = {
          switch = "nh os switch";
          test = "nh os test";
          "1password" = "1password --ozone-platform-hint=auto";
          #        ns = "nix-search-tv print | fzf --preview='nix-search-tv preview {}' --scheme=history";
        };
      };
      carapace.enable = true;
      carapace.enableNushellIntegration = true;
    };
  };
}

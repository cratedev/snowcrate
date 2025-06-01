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
      zoxide = {
        enable = true;
        options = ["--cmd" "cd"];
      };
      carapace.enable = true;
      carapace.enableNushellIntegration = true;
      starship = {
        enable = true;
        enableNushellIntegration = true;
        settings = {
          format = "$directory$all$cmd_duration$jobs$status$shell$line_break$env_var$username$sudo$character";
          right_format = "$battery$time";
          add_newline = true;
          character = {
            format = "$symbol ";
            success_symbol = "[●](bright-green)";
            error_symbol = "[●](red)";
            vicmd_symbol = "[◆](blue)";
          };
          sudo = {
            format = "[$symbol]($style)";
            style = "bright-purple";
            symbol = ":";
            disabled = true;
          };
          username = {
            style_user = "yellow bold";
            style_root = "purple bold";
            format = "[$user]($style) ▻ ";
            disabled = false;
            show_always = false;
          };
          directory = {
            home_symbol = "⌂";
            truncation_length = 2;
            truncation_symbol = "□ ";
            read_only = " △";
            use_os_path_sep = true;
            style = "bright-blue";
          };
          git_branch = {
            format = "[$symbol $branch(:$remote_branch)]($style) ";
            symbol = "[△](green)";
            style = "green";
          };
          git_status = {
            format = "($ahead_behind$staged$renamed$modified$untracked$deleted$conflicted$stashed)";
            conflicted = "[◪ ]( bright-magenta)";
            ahead = "[▲ [$count](bold white) ](green)";
            behind = "[▼ [$count](bold white) ](red)";
            diverged = "[◇ [$ahead_count](bold green)/[$behind_count](bold red) ](bright-magenta)";
            untracked = "[○ ](bright-yellow)";
            stashed = "[$count ](bold white)";
            renamed = "[● ](bright-blue)";
            modified = "[● ](yellow)";
            staged = "[● ](bright-cyan)";
            deleted = "[✕ ](red)";
          };
          deno = {
            format = "deno [∫ $version](blue ) ";
            version_format = "$major.$minor";
          };
          nodejs = {
            format = "node [◫ ($version)]( bright-green) ";
            detect_files = ["package.json"];
            version_format = "$major.$minor";
          };
          rust = {
            format = "rs [$symbol$version]($style) ";
            symbol = "⊃ ";
            version_format = "$major.$minor";
            style = "red";
          };
          package = {
            format = "pkg [$symbol$version]($style) ";
            version_format = "$major.$minor";
            symbol = "◫ ";
            style = "bright-yellow ";
          };
          nix_shell = {
            symbol = "⊛ ";
            format = "nix [$symbol$state $name]($style) ";
          };
        };
      };
    };
  };
}

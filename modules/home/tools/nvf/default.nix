{
  config,
  lib,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.tools.nvf;
in {
  options.${namespace}.tools.nvf = with types; {
    enable = mkBoolOpt false "Whether or not to enable common Neovim.";
  };

  imports = [inputs.nvf.homeManagerModules.default];
  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      settings.vim = {
        theme = {
          enable = true;
          transparent = true;
        };

        options = {
          tabstop = 2;
          shiftwidth = 2;
          softtabstop = 2;
          expandtab = false;
        };

        keymaps = [
          {
            key = "<leader><Left>";
            mode = "n";
            action = "<cmd>bprev<CR>";
            silent = true;
          }
          {
            key = "<leader><Right>";
            mode = "n";
            action = "<cmd>bnext<CR>";
            silent = true;
          }
          {
            key = "<";
            mode = "v";
            action = "<gv";
            desc = "Unindent and reselect";
          }
          {
            key = ">";
            mode = "v";
            action = ">gv";
            desc = "Indent and reselect";
          }
        ];

        globals = {
          mapleader = " "; # Set your preferred leader key
        };

        viAlias = true;
        vimAlias = true;

        debugMode = {
          enable = false;
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          lightbulb.enable = true;
          trouble.enable = true;
          lspSignature.enable = true;
        };

        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;
          nix = {
            enable = true;
            lsp = {
              enable = true;
              servers = [
                "nixd"
              ];
            };
          };
          assembly.enable = false;
          astro.enable = false;
          nu.enable = false;
          csharp.enable = false;
          julia.enable = false;
          vala.enable = false;
          scala.enable = false;
          r.enable = false;
          gleam.enable = false;
          dart.enable = false;
          ocaml.enable = false;
          elixir.enable = false;
          haskell.enable = false;
          ruby.enable = false;

          tailwind.enable = false;
          svelte.enable = false;
          nim.enable = false;
        };

        visuals = {
          nvim-web-devicons.enable = true;
          cinnamon-nvim.enable = true;
          fidget-nvim.enable = true;
          highlight-undo.enable = false;
          indent-blankline = {
            enable = true;
            setupOpts = {
            };
          };
          nvim-cursorline = {
            enable = true;
            setupOpts.line_timeout = 0;
          };
        };

        statusline = {
          lualine = {
            enable = true;
          };
        };

        autopairs.nvim-autopairs = {
          enable = true;
          setupOpts = {};
        };

        autocomplete.nvim-cmp = {
          enable = true;
          setupOpts = {};
        };

        snippets.luasnip.enable = true;

        filetree = {
          nvimTree = {
            enable = true;
            setupOpts = {};
          };
        };

        tabline = {
          nvimBufferline = {
            enable = true;
            setupOpts = {};
          };
        };

        treesitter.context.enable = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        telescope.enable = true;

        git = {
          enable = true;
          gitsigns = {
            enable = true;
            codeActions.enable = false;
          };
        };

        minimap = {
          minimap-vim.enable = false;
        };
        dashboard = {
          startify.enable = true;
        };

        notify = {
          nvim-notify = {
            enable = true;
            setupOpts = {
              background_colour = "#000000";
            };
          };
        };

        utility = {
          diffview-nvim.enable = true;
          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = true;
          };
        };

        notes = {
          todo-comments.enable = true;
        };
        comments = {
          comment-nvim.enable = true;
        };

        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = true;
            setupOpts = {};
          };
        };

        ui = {
          borders.enable = true;
          noice = {
            enable = true;
            setupOpts = {};
          };
          colorizer.enable = true;
          illuminate.enable = true;
          modes-nvim.enable = false;
          smartcolumn = {
            enable = false;
            setupOpts = {
              custom_colorcolumn = {
                nix = "110";
                ruby = "120";
                java = "130";
                go = [
                  "90"
                  "130"
                ];
              };
            };
          };

          fastaction.enable = true; # Replaces nvim-code-action-menu

          breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
            lualine.winbar = {
              enable = true; # Controls navic integration with lualine
              alwaysRender = false;
            };
          };
        };

        assistant = {
          chatgpt.enable = false;
          copilot.enable = false;
        };

        session = {
          nvim-session-manager.enable = false;
        };
        gestures = {
          gesture-nvim.enable = false;
        };
      };
    };
  };
}

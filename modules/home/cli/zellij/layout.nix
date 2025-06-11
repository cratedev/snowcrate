{colors}:
/*
kdl
*/
''
  layout {
    default_tab_template {
      pane size=1 borderless=true {
        plugin location="file:$HOME/.config/zellij/plugins/zjstatus.wasm" {
          // Nord theme
          color_fg "#616e88" //= Brightest + 10% - "#4C566A" = Brightest - "#434C5E" = Bright
          color_bg "#2E3440"
          color_black "#3B4252"
          color_red "#BF616A"
          color_green "#A3BE8C"
          color_yellow "#EBCB8B"
          color_blue "#81A1C1"
          color_magenta "#B48EAD"
          color_cyan "#88C0D0"
          color_white "#E5E9F0"
          color_orange "#D08770"

          format_left   "#[fg=#${colors.base00},bold]{session}"
          format_center "{tabs}"
          format_right  "{command_git_branch} {datetime}"
          format_space  ""

          border_enabled  "false"
          border_char     "─"
          border_format   "#[fg=#${colors.base00}]{char}"
          border_position "top"

          hide_frame_for_single_pane "false"

  		mode_normal        "#[bg=#${colors.base0B},fg=#${colors.base02},bold] NORMAL#[bg=#${colors.base03},fg=#${colors.base0B}]█"
  		mode_locked        "#[bg=#${colors.base04},fg=#${colors.base02},bold] LOCKED #[bg=#${colors.base03},fg=#${colors.base04}]█"
  			mode_resize        "#[bg=#${colors.base08},fg=#${colors.base02},bold] RESIZE#[bg=#${colors.base03},fg=#${colors.base08}]█"
                    mode_pane          "#[bg=#${colors.base0D},fg=#${colors.base02},bold] PANE#[bg=#${colors.base03},fg=#${colors.base0D}]█"
                    mode_tab           "#[bg=#${colors.base07},fg=#${colors.base02},bold] TAB#[bg=#${colors.base03},fg=#${colors.base07}]█"
                    mode_scroll        "#[bg=#${colors.base0A},fg=#${colors.base02},bold] SCROLL#[bg=#${colors.base03},fg=#${colors.base0A}]█"
                    mode_enter_search  "#[bg=#${colors.base0D},fg=#${colors.base02},bold] ENT-SEARCH#[bg=#${colors.base03},fg=#${colors.base0D}]█"
                    mode_search        "#[bg=#${colors.base0D},fg=#${colors.base02},bold] SEARCHARCH#[bg=#${colors.base03},fg=#${colors.base0D}]█"
                    mode_rename_tab    "#[bg=#${colors.base07},fg=#${colors.base02},bold] RENAME-TAB#[bg=#${colors.base03},fg=#${colors.base07}]█"
                    mode_rename_pane   "#[bg=#${colors.base0D},fg=#${colors.base02},bold] RENAME-PANE#[bg=#${colors.base03},fg=#${colors.base0D}]█"
                    mode_session       "#[bg=#${colors.base0E},fg=#${colors.base02},bold] SESSION#[bg=#${colors.base03},fg=#${colors.base0E}]█"
                    mode_move          "#[bg=#${colors.base0F},fg=#${colors.base02},bold] MOVE#[bg=#${colors.base03},fg=#${colors.base0F}]█"
                    mode_prompt        "#[bg=#${colors.base0D},fg=#${colors.base02},bold] PROMPT#[bg=#${colors.base03},fg=#${colors.base0D}]█"
                    mode_tmux          "#[bg=#${colors.base09},fg=#${colors.base02},bold] TMUX#[bg=#${colors.base03},fg=#${colors.base09}]█"

                    // formatting for inactive tabs
                    tab_normal              "#[bg=#${colors.base01},fg=#${colors.base02}] #[bg=#${colors.base01},fg=#${colors.base05},bold]{index} #[bg=#${colors.base00},fg=#${colors.base05},bold] {name}{floating_indicator}#[bg=#${colors.base00},fg=#${colors.base05},bold] "
                    tab_normal_fullscreen   "#[bg=#${colors.base03},fg=#${colors.base0D}] #[bg=#${colors.base0D},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{fullscreen_indicator}#[bg=#${colors.base09},fg=#${colors.base02},bold] "
                    tab_normal_sync         "#[bg=#${colors.base03},fg=#${colors.base0D}] #[bg=#${colors.base0D},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{sync_indicator}#[bg=#${colors.base09},fg=#${colors.base02},bold] "

                    // formatting for the current active tab
                    tab_active              "#[bg=#${colors.base0D},fg=#${colors.base02}] #[bg=#${colors.base0D},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{floating_indicator}#[bg=#${colors.base02},fg=#${colors.base05},bold] "
                    tab_active_fullscreen   "#[bg=#${colors.base0D},fg=#${colors.base09}] #[bg=#${colors.base09},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{fullscreen_indicator}#[bg=#${colors.base0D},fg=#${colors.base02},bold] "
                    tab_active_sync         "#[bg=#${colors.base0D},fg=#${colors.base09}] #[bg=#${colors.base09},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{sync_indicator}#[bg=#${colors.base0D},fg=#${colors.base02},bold] "

                    // separator between the tabs
                    tab_separator           "#[bg=#${colors.base00}] "

          // indicators
          tab_sync_indicator       " "
          tab_fullscreen_indicator " 󰊓"
          tab_floating_indicator   " 󰹙"

          command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
          command_git_branch_format      "#[fg=blue] {stdout} "
          command_git_branch_interval    "10"
          command_git_branch_rendermode  "static"

          datetime        "#[fg=#6C7086,bold] {format} "
          datetime_format "%A, %d %b %Y %H:%M"
          datetime_timezone "America/Toronto"
        }
      }
   pane split_direction="horizontal" {
  		borderless false
  }
   pane {
        borderless true
        size 1
        plugin location="zellij:status-bar"
      }
  }
  }''

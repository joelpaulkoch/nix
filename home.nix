{
  config,
  pkgs,
  next-ls,
  ghostty,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "joel";
  home.homeDirectory = "/home/joel";

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting

        if type -q mise
          ~/.local/bin/mise activate fish | source
        end
      '';
      plugins = [
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
        {
          name = "plugin-git";
          src = pkgs.fishPlugins.plugin-git.src;
        }
      ];
    };

    bash = {
      enable = true;
      initExtra = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      userName = "Joel Koch";
      userEmail = "joel@joelkoch.dev";
    };

    helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "onedark";
        editor = {
          auto-save = true;
          line-number = "relative";
          file-picker.hidden = false;
          lsp.display-messages = true;
        };
      };
      languages = {
        language-server = {
          nextls = {
            command = "nextls";
            args = ["--stdio=true"];
            config = {experimental = {completions = {enable = true;};};};
            environment = {"NEXTLS_SPITFIRE_ENABLED" = "1";};
          };

          tailwind-heex = {
            command = "tailwindcss-language-server";
            args = ["--stdio"];
          };
          nil = {
            command = "nil";
            config = {nil.formatting = {command = ["alejandra"];};};
          };
        };

        language = [
          {
            name = "nix";
            language-servers = ["nil"];
            auto-format = true;
          }
          {
            name = "elixir";
            language-servers = ["nextls"];
            auto-format = true;
            roots = ["mix.exs"];
            scope = "source.elixir";
          }
          {
            name = "heex";
            language-servers = ["nextls" "tailwindcss-language-server"];
            auto-format = true;
          }
        ];
      };
    };
  };

  home.packages = with pkgs;
    [
      act
      alejandra
      asciinema
      bat
      bottom
      flyctl
      fzf
      gh
      glab
      htop
      jq
      lazygit
      lazysql
      ncdu
      neofetch
      nil
      ripgrep
      tailwindcss-language-server
      tokei
      tree
      xclip
      xh
      yazi
    ]
    ++ [
      next-ls.packages.${pkgs.system}.default
      ghostty.packages.${pkgs.system}.default
    ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/ghostty/config".text = ''
      keybind = super+enter=new_split:auto

      keybind = super+left_bracket=goto_split:previous
      keybind = super+right_bracket=goto_split:next

      keybind = shift+super+enter=toggle_split_zoom

      keybind = ctrl+shift+tab=previous_tab
      keybind = ctrl+tab=next_tab

      window-decoration = false

      gtk-tabs-location = bottom

      shell-integration = fish
    '';
  };

  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  home.shellAliases = {
    l = "ls -lAh1";

    hm = "home-manager";

    nixup = "nix flake update ~/nix";
    hmsw = "home-manager switch --flake ~/nix";

    lg = "lazygit";
    lsql = "lazysql";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

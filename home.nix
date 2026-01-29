{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kitagawa_zempei";
  home.homeDirectory = "/Users/${config.home.username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    pkgs.fzf-git-sh
    pkgs.nixd
    pkgs.nixfmt
    pkgs.ghq
    pkgs.zellij

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # Login shell environment (Nix PATH, Homebrew, etc.)
    ".zprofile".source = ./zsh/.zprofile;

    # Zellij config
    ".config/zellij/config.kdl".source = ./zellij/config.kdl;

    # Zellij script
    ".config/zellij/prompt-editor.sh" = {
      source = ./zellij/prompt-editor.sh;
      executable = true;
    };

    # Helix script
    ".config/helix/yazi-picker.sh" = {
      source = ./.helix/yazi-picker.sh;
      executable = true;
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/kitagawa_zempei/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # コマンド履歴設定
    history = {
      size = 10000; # メモリ上の履歴件数
      save = 10000; # ファイルに保存する件数
      path = "$HOME/.zsh_history";
      ignoreAllDups = true; # 全ての重複を削除（古い方を消す）
      share = true; # セッション間で共有
      append = true; # 即座に履歴ファイルに追記
    };

    initContent = ''
      # fzf-gitのインストール
      source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh

      # .zshrcの読み込み
      ${builtins.readFile ./zsh/.zshrc}
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      command_timeout = 1000;
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        nerdFontsVersion = "3";
      };
      git = {
        pagers = [
          {
            "pager" = ''
              delta --dark --paging=never --line-numbers --hyperlinks \
                --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"
            '';
          }
        ];
      };
      os = {
        editPreset = "helix (hx)";
      };
    };
  };

  programs.helix = {
    enable = true;

    # LSPツールをPATHに追加
    extraPackages = [
      pkgs.pyright
      pkgs.ruff
    ];

    # config.toml
    settings = {
      theme = "ayu_dark_transparent";
      editor = {
        line-number = "relative";
        mouse = true;
        scrolloff = 5;
        shell = [
          "zsh"
          "-c"
        ];
        auto-save = true;
        bufferline = "multiple";
        color-modes = true;
        end-of-line-diagnostics = "warning";
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "disable";
        };
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "file-modification-indicator"
          ];
          center = [ "file-type" ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
          ];
        };
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        file-picker.hidden = false;
        search = {
          smart-case = true;
          wrap-around = true;
        };
        whitespace.render = "all";
        indent-guides = {
          render = true;
          character = "╎";
        };
        soft-wrap.enable = false;
        smart-tab = {
          enable = true;
        };
        lsp.auto-signature-help = false;
        lsp.display-messages = true;
      };
      keys = {
        normal = {
          esc = [
            ":sh macism com.apple.keylayout.ABC"
            "normal_mode"
          ];
          C-l = [
            ":write-all"
            ":new"
            ":insert-output lazygit"
            ":buffer-close!"
            ":redraw"
            ":reload-all"
          ];
          C-y = [
            ":sh zellij run -n Yazi -c -f -x 10%% -y 10%% --width 80%% --height 80%% -- bash ~/.config/helix/yazi-picker.sh open '%{buffer_name}'"
          ];
          space.c = ":sh echo '@%{buffer_name}' | pbcopy";
        };
        select = {
          space.c = ":sh echo '@%{buffer_name}:%{selection_line_start}-%{selection_line_end}' | pbcopy";
        };
        insert = {
          esc = [
            ":sh macism com.apple.keylayout.ABC"
            "normal_mode"
          ];
        };
      };
    };
    # languages.toml
    languages = {
      language = [
        {
          name = "python";
          language-servers = [
            "pyright"
            "ruff"
          ];
          formatter = {
            command = "ruff";
            args = [
              "format"
              "-"
            ];
          };
          auto-format = true;
        }
        {
          name = "markdown";
          soft-wrap.enable = true;
        }
        {
          name = "nix";
          language-servers = [ "nixd" ];
          formatter = {
            command = "nixfmt";
          };
          auto-format = true;
        }
      ];
      language-server = {
        pyright = {
          command = "pyright-langserver";
          args = [ "--stdio" ];
        };
        ruff = {
          command = "ruff";
          args = [
            "server"
            "--preview"
          ];
        };
        nixd = {
          command = "nixd";
          args = [ "--semantic-tokens=true" ];
          config.nixd = {
            nixpkgs.expr = "import <nixpkgs> {}";
          };
        };
      };
    };
    themes = {
      ayu_dark_transparent = {
        "inherits" = "ayu_dark";
        "ui.background" = { };
      };
    };
  };

  programs.delta = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd -t f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd -t f -t d --hidden --follow --exclude .git";
    fileWidgetOptions = [ "--preview 'bat --color=always {}'" ];
  };

  programs.fd = {
    enable = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };
}

{ pkgs, ... }:

{
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
          language-servers = [
            "nixd"
            "nil"
          ];
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
        nil = {
          command = "nil";
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
}

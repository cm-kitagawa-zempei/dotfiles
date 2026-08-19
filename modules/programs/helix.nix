{ pkgs, ... }:

{
  programs.helix = {
    enable = true;

    # LSPツールをPATHに追加
    extraPackages = [
      pkgs.pyright
      pkgs.ruff
      pkgs.marksman
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
          # lazygit と同じ :insert-output 方式でペイン内に yazi を全画面表示
          C-y = [
            ":insert-output bash ~/.config/helix/yazi-picker.sh '%{buffer_name}'"
            ":open %sh{bash ~/.config/helix/yazi-picker.sh --paths}"
            ":redraw"
          ];
          space.c = ":sh echo '%{buffer_name}' | pbcopy";
          # Arto (GUI, Homebrew cask 管理: arto-app/tap/arto) で Markdown を
          # プレビュー。Nix だと毎回ソースビルドになるため cask にしている。
          # 単一インスタンスなので2回目以降は既存ウィンドウにルーティング
          # される。初回起動がブロックしないようバックグラウンドで起動する。
          # CLI 直接実行は LaunchServices を経由せず、macOS の cooperative
          # activation に前面化を却下されることがあるため open -a で確実に
          # 前面化する
          #   m   = 現在のファイルのみ
          #   S-m = workspace root（Git ルート、リポジトリ外は cwd）を
          #         エクスプローラーのルートにして現在のファイルを開く
          space.m = ":sh nohup arto \"$(realpath '%{buffer_name}')\" > /dev/null 2>&1 & open -a Arto";
          space.S-m = ":sh nohup arto --directory=\"$(git rev-parse --show-toplevel 2>/dev/null || pwd)\" \"$(realpath '%{buffer_name}')\" > /dev/null 2>&1 & open -a Arto";
          A-c = "copy_selection_on_prev_line";
        };
        select = {
          space.c = ":sh echo '%{buffer_name}:%{selection_line_start}-%{selection_line_end}' | pbcopy";
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
          language-servers = [ "marksman" ];
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
        marksman = {
          command = "marksman";
          args = [ "server" ];
          # nixpkgsのmarksmanはICUをLD_LIBRARY_PATH(Linux用)で渡すため
          # macOSではICU初期化に失敗して起動できない。ICU不使用モードで回避
          environment = {
            DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
          };
        };
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
        "ui.linenr" = {
          fg = "#bfbdb6";
        };
        "ui.linenr.selected" = {
          fg = "#FFFFFF";
        };
        "ui.selection" = {
          bg = "#264F78";
        };
        "ui.selection.primary" = {
          bg = "#264F78";
        };
      };
    };
  };
}

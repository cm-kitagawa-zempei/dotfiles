{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # コマンド履歴設定
    history = {
      size = 100000; # メモリ上の履歴件数
      save = 100000; # ファイルに保存する件数
      path = "$HOME/.zsh_history";
      extended = true; # 全行にタイムスタンプを付与（: <ts>:<dur>;<cmd>形式で統一）
      ignoreAllDups = true; # メモリ上で全ての重複を削除（古い方を消す）
      saveNoDups = true; # ファイル保存時も重複をスキップ
      findNoDups = true; # Ctrl-R/↑ 検索で重複を飛ばす
      expireDuplicatesFirst = true; # size超過時は重複から先に破棄
      ignoreSpace = true; # 行頭スペースで始まるコマンドは記録しない
      share = true; # セッション間で共有
      append = true; # 即座に履歴ファイルに追記
    };

    initContent = ''
      # fzf-gitのインストール
      source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh

      # .zshrcの読み込み
      ${builtins.readFile ../../config/zsh/.zshrc}
    '';

    profileExtra = ''
      # Homebrew shellenv
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      command_timeout = 1000;
    };
  };
}

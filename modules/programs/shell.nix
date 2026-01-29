{ pkgs, ... }:

{
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
      ${builtins.readFile ../../zsh/.zshrc}
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      command_timeout = 1000;
    };
  };
}

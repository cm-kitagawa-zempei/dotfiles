# 管理状況

このファイルは、各ツールの管理状況（Nix/Homebrew）を追跡します。

## Nix/Home Manager で管理中

| 項目 | 設定場所 | 備考 |
|------|---------|------|
| zsh | `programs.zsh` | `initContent`で`.zshrc`を読み込み |
| zsh-autosuggestion | `programs.zsh.autosuggestion` | コマンド履歴からの自動提案 |
| zsh-syntax-highlighting | `programs.zsh.syntaxHighlighting` | コマンドのシンタックスハイライト |
| starship | `programs.starship` | プロンプト |
| lazygit | `programs.lazygit` | `settings`で設定も管理 |
| delta | `programs.delta` | Git diffツール |
| fzf-git-sh | `home.packages` | fzf + Git統合 |
| nixd | `home.packages` | Nix LSP |
| nixfmt-rfc-style | `home.packages` | Nixフォーマッタ（公式） |

## Homebrew で管理中（移行候補）

`.zshrc`の分析に基づく:

| ツール | 用途 | 移行優先度 |
|--------|------|-----------|
| fzf | ファジーファインダー | 高（`programs.fzf`で管理可能） |
| fd | findの代替 | 中 |
| bat | catの代替 | 中（`programs.bat`で管理可能） |
| eza | lsの代替 | 中（`programs.eza`で管理可能） |
| gh | GitHub CLI | 中（`programs.gh`で管理可能） |
| ghq | Gitリポジトリ管理 | 中 |
| z | ディレクトリジャンプ | 低（`programs.zoxide`で代替検討） |
| git-extras | Git拡張コマンド | 低 |
| nodebrew | Node.jsバージョン管理 | 低 |
| uv | Pythonパッケージマネージャ | 低 |

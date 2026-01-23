# 管理状況

このファイルは、各ツールの管理状況（Nix/Homebrew/その他）を追跡します。

## Nix/Home Manager で管理中

| 項目 | 設定場所 | 備考 |
|------|---------|------|
| zsh | `programs.zsh` | `initContent`で`.zshrc`を読み込み |
| zsh履歴設定 | `programs.zsh.history` | size/save/ignoreAllDups/share/append |
| zsh-autosuggestion | `programs.zsh.autosuggestion` | コマンド履歴からの自動提案 |
| zsh-syntax-highlighting | `programs.zsh.syntaxHighlighting` | コマンドのシンタックスハイライト |
| starship | `programs.starship` | プロンプト |
| lazygit | `programs.lazygit` | `settings`で設定も管理 |
| delta | `programs.delta` | Git diffツール |
| fzf | `programs.fzf` | ファジーファインダー、zsh統合、fd/bat連携 |
| fzf-git-sh | `home.packages` | fzf + Git統合 |
| fd | `programs.fd` | findの代替、fzfのファイル検索で使用 |
| bat | `programs.bat` | catの代替、fzfのプレビューで使用 |
| eza | `programs.eza` | lsの代替、zsh統合でエイリアス自動設定 |
| nixd | `home.packages` | Nix LSP |
| nixfmt | `home.packages` | Nixフォーマッタ |

## Homebrew で管理中（移行候補）

`.zshrc`の分析に基づく:

| ツール | 用途 | 移行優先度 |
|--------|------|-----------|
| gh | GitHub CLI | 中（`programs.gh`で管理可能） |
| ghq | Gitリポジトリ管理 | 中（`home.packages`で管理可能） |
| z | ディレクトリジャンプ | 低（`programs.zoxide`で代替検討） |
| git-extras | Git拡張コマンド | 低 |
| nodebrew | Node.jsバージョン管理 | 低（専用ツールのため移行非推奨） |
| uv | Pythonパッケージマネージャ | 低（`home.packages`で管理可能） |
| libpq | PostgreSQLクライアントライブラリ | 低 |

## その他のツール（dotfiles管理外）

| ツール | 管理方法 | 備考 |
|--------|---------|------|
| Rust/Cargo | rustup | `~/.cargo/env`から読み込み |
| Rancher Desktop | アプリケーション | `~/.rd/bin`をPATHに追加 |
| SnowSQL | アプリケーション | `/Applications/SnowSQL.app` |
| pnpm | 独自インストール | `~/Library/pnpm` |
| kiro | 不明 | シェル統合あり |
| Antigravity | 不明 | `~/.antigravity`から読み込み |

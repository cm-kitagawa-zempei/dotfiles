# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

macOS (aarch64-darwin) 向けdotfilesリポジトリ。Nix Flakes + Home Managerで宣言的に管理。
詳細なガイドラインは `AGENTS.md` を参照。

## Commands

```bash
# 設定を適用
home-manager switch --flake . -b backup

# ビルドのみ（適用せず確認）
home-manager build --flake .

# Flake整合性チェック
nix flake check

# 依存関係を更新
nix flake update

# Nixフォーマット
nixfmt flake.nix home.nix modules/home/*.nix modules/programs/*.nix

# パッケージ検索
nix search nixpkgs <package-name>

# エラー詳細表示
home-manager switch --flake . --show-trace
```

## Architecture

エントリポイントは `flake.nix` -> `home.nix` -> `modules/` の順に読み込まれる。

- `home.nix` — imports とコア設定（ユーザー名、環境変数）のみ
- `modules/home/packages.nix` — `home.packages`（設定不要なパッケージ）
- `modules/home/files.nix` — `home.file` / `xdg.configFile`（設定ファイルのシンボリックリンク）
- `modules/programs/shell.nix` — zsh / starship（`config/zsh/.zshrc`を`builtins.readFile`で読み込み）
- `modules/programs/cli.nix` — fzf / fd / bat / eza / zoxide / yazi
- `modules/programs/git.nix` — lazygit / delta / gh
- `modules/programs/helix.nix` — Helix エディタ（LSP / 言語 / テーマ設定含む）
- `config/` — Nix外の設定ファイル（zsh, zellij, helix scripts）。`modules/home/files.nix`経由でリンクされる

## Conventions

- Nixコードは `nixfmt`（RFC 166準拠）でフォーマット
- コミットメッセージ: `<type>: <description>`（type: feat/fix/refactor/docs/chore）
- ツール追加時の判断:
  - 設定不要 → `modules/home/packages.nix` に追加
  - 設定あり → `modules/programs/*.nix` で `programs.<name>` を使用
  - シェル統合あり → `enableZshIntegration = true` を活用
- `home.nix` にはツール設定を直接書かず、必ず modules/ に分割
- Homebrew管理ツールを段階的にNixへ移行中（現状は `STATUS.md` 参照）
- コミットメッセージにCo-Authored-Byを付けない

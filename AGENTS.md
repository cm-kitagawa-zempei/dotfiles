# AGENTS.md

このドキュメントは、AIエージェントがこのdotfilesリポジトリを理解し、適切に変更を加えるためのガイドラインです。

## プロジェクト概要

このリポジトリは、macOS (aarch64-darwin) 環境のdotfilesを**Nix Flakes + Home Manager**で宣言的に管理しています。

### 管理方針

- **宣言的な設定管理**: 設定ファイルをNixで記述し、再現性のある環境構築を実現
- **段階的な移行**: Homebrewで管理していたツールを順次Nixへ移行中
- **シンプルな構成**: 複雑なモジュール分割は避け、必要最小限のファイル構成を維持

## ディレクトリ構成

```
dotfiles/
├── flake.nix       # Nixフレーク設定（エントリポイント）
├── flake.lock      # 依存関係のロックファイル（自動生成）
├── home.nix        # Home Manager設定（パッケージ・プログラム管理）
├── nix/
│   └── nix.conf    # Nix自体の設定（flakes有効化など）
└── zsh/
    ├── .zprofile   # zshプロファイル（ログインシェル用）
    └── .zshrc      # zsh設定（インタラクティブシェル用）
```

### 各ファイルの役割

| ファイル | 役割 |
|---------|------|
| `flake.nix` | 依存関係（inputs）と出力（homeConfigurations）を定義。エントリポイント |
| `home.nix` | ユーザー設定のメイン。パッケージ、プログラム、環境変数を管理 |
| `nix/nix.conf` | Nixの設定。`experimental-features = nix-command flakes`で新機能を有効化 |
| `zsh/.zshrc` | zshの設定。Home Managerの`programs.zsh.initContent`から読み込まれる |
| `zsh/.zprofile` | Homebrewの初期化など、ログイン時に実行される設定 |

## Nix/Home Manager 基礎知識

### flake.nix の構造

```nix
{
  inputs = {
    # 依存関係を宣言
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    # Home Manager設定を出力
    homeConfigurations."kitagawa_zempei" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [ ./home.nix ];
    };
  };
}
```

### home.nix の主要セクション

| セクション | 用途 |
|-----------|------|
| `home.packages` | パッケージのみインストール（設定なし） |
| `programs.<name>` | パッケージ + 設定を宣言的に管理 |
| `home.file` | ドットファイルのシンボリックリンク管理 |
| `home.sessionVariables` | 環境変数の設定 |

## 現在の管理状況

各ツールのNix/Homebrew管理状況は @STATUS.md を参照。

## ツール追加パターン

### パターン1: home.packages に追加（設定不要なツール）

```nix
# home.nix
home.packages = [
  pkgs.ripgrep    # 設定不要なCLIツール
  pkgs.jq
];
```

**使用ケース**: 設定ファイルが不要で、パスが通っていれば使えるツール

### パターン2: programs.<name>.enable = true（設定込みツール）

```nix
# home.nix
programs.starship = {
  enable = true;
  settings = {
    # starship.tomlの内容をNixで記述
    add_newline = false;
  };
};
```

**使用ケース**: 設定ファイルも一緒に管理したいツール

### パターン3: programs.<name> + シェル設定の移行

```nix
# home.nix
programs.fzf = {
  enable = true;
  enableZshIntegration = true;  # .zshrcへの設定追加を自動化
};
```

**使用ケース**: シェル統合が必要なツール（fzf, starshipなど）

## Brew → Nix 移行ガイドライン

### 移行手順

1. **パッケージ確認**: `nix search nixpkgs <package>` で存在確認
2. **設定方法確認**: `programs.<name>`が使えるかHome Manager公式ドキュメントで確認
3. **設定追加**: `home.nix`に追加
4. **適用**: `home-manager switch --flake .`
5. **動作確認**: ツールが正常に動作することを確認
6. **Brewから削除**: `brew uninstall <package>`
7. **.zshrcから設定削除**: 不要になった設定を削除

### 移行時の注意点

- **段階的に移行**: 一度に多くのツールを移行しない
- **ロールバック可能**: `home-manager generations`で過去の世代に戻れる
- **Brew設定の残存確認**: `.zshrc`や`.zprofile`にBrew依存の設定が残っていないか確認

## コマンドリファレンス

### 基本コマンド

```bash
# 設定を適用（最も頻繁に使用）
home-manager switch --flake .

# 依存関係を更新（nixpkgs、home-managerのバージョン更新）
nix flake update

# 世代一覧を表示
home-manager generations

# 過去の世代にロールバック
home-manager activate <generation-path>

# パッケージを検索
nix search nixpkgs <package-name>

# 設定をビルド（適用せずに確認）
home-manager build --flake .
```

### デバッグコマンド

```bash
# Flakeの評価エラーを確認
nix flake check

# 詳細なビルドログを表示
home-manager switch --flake . --show-trace

# 利用可能なHome Managerオプションを検索
man home-configuration.nix
```

## コーディング規約

### フォーマッタ

Nixコードは `nixfmt-rfc-style`（RFC 166準拠の公式フォーマッタ）でフォーマットする。

```bash
# フォーマット実行
nixfmt flake.nix home.nix

# 差分確認のみ（CI向け）
nixfmt --check flake.nix home.nix
```

### コメント規則

```nix
# セクション区切りには説明を付ける
# =============================================================================
# プログラム設定
# =============================================================================

# 単一行コメントは設定の上に記述
# Lazygit: TUIベースのGitクライアント
programs.lazygit = {
  enable = true;
};
```

### ファイル管理

- **1つのファイルで管理できる範囲を超えたらモジュール分割を検討**
- **現状は`home.nix`に集約**（設定量が少ないため）

### zsh設定の扱い

- `zsh/.zshrc`は`programs.zsh.initContent`から`builtins.readFile`で読み込まれる
- **新しいシェル設定**: 可能な限り`programs.<name>.enableZshIntegration`を活用
- **カスタム関数やエイリアス**: `zsh/.zshrc`に記述を継続

## よくある操作例

### 新しいCLIツールを追加する

```nix
# home.nix の home.packages に追加
home.packages = [
  pkgs.fzf-git-sh
  pkgs.nixd
  pkgs.ripgrep  # 新規追加
];
```

### programs経由でツールを追加する

```nix
# home.nix に追加
programs.bat = {
  enable = true;
  config = {
    theme = "TwoDark";
  };
};
```

### 環境変数を追加する

```nix
# home.nix の home.sessionVariables に追加
home.sessionVariables = {
  EDITOR = "nvim";
  LANG = "en_US.UTF-8";
};
```

## テスト手順

### 変更前の確認

```bash
# 構文エラーがないか確認（適用せずにビルドのみ）
home-manager build --flake .

# Flakeの整合性チェック
nix flake check
```

### 変更後の検証

1. **設定適用**: `home-manager switch --flake .`
2. **新しいシェルセッションを開く**: 設定変更を反映
3. **動作確認**: 追加したツールやエイリアスが動作することを確認
4. **問題発生時**: `home-manager generations` で過去の世代に戻る

### よくあるエラー

| エラー | 原因 | 解決方法 |
|--------|------|---------|
| `attribute 'xxx' missing` | パッケージ名の誤り | `nix search nixpkgs <name>` で正しい名前を確認 |
| `infinite recursion` | 循環参照 | `imports` や変数参照を確認 |
| `syntax error` | Nix構文エラー | セミコロン、括弧の閉じ忘れを確認 |

## セキュリティ考慮事項

### コミットしてはいけないもの

- **シークレット・認証情報**: APIキー、パスワード、トークン
- **個人情報**: メールアドレス、IPアドレス（設定ファイル内）
- **ローカル環境固有のパス**: 他の環境で動作しない絶対パス

### 安全な管理方法

```nix
# 悪い例: シークレットをハードコード
home.sessionVariables = {
  API_KEY = "sk-xxxx";  # NG: コミットされてしまう
};

# 良い例: 環境変数や外部ファイルから読み込み
# シークレットは .gitignore で除外
```

### シェルスクリプトの注意点

- `eval` や `source` で外部スクリプトを実行する際は信頼できるソースか確認
- Homebrew経由の設定（`$(brew --prefix)`）は信頼できるが、任意のURLからの読み込みは避ける

## コミットメッセージ規約

### フォーマット

```
<type>: <description>

[optional body]
```

### Type一覧

| Type | 用途 |
|------|------|
| `feat` | 新しいツールやパッケージの追加 |
| `fix` | バグ修正、設定の修正 |
| `refactor` | 動作を変えないリファクタリング |
| `docs` | ドキュメントの変更 |
| `chore` | 依存関係の更新など |

### 例

```
feat: add starship prompt via programs.starship

Migrated from Homebrew to Nix for declarative configuration.
```

```
fix: correct fzf preview command for directories
```

```
chore: update flake.lock
```

## PR/変更時のチェックリスト

- [ ] `home-manager build --flake .` が成功する
- [ ] 新しいシェルセッションで動作確認済み
- [ ] シークレットや個人情報が含まれていない
- [ ] 必要に応じて`.zshrc`からBrew依存の設定を削除
- [ ] AGENTS.mdの「現在の管理状況」を更新（ツール移行時）

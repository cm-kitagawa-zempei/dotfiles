# dotfiles with Nix and Home Manager

このリポジトリでは [Home Manager](https://github.com/nix-community/home-manager) を使用してdotfilesを管理します。
Home ManagerはNixをベースとしているので、前提としてNixのインストールを行う必要があります。

## Nix install

Nixをインストールする方法はいくつかあります。

- [公式Nix](https://github.com/NixOS/nix)
- [Determinate Nix](https://github.com/DeterminateSystems/nix-installer)
- [Lix](https://github.com/lix-project/lix)

またそれぞれがインストールするNixも異なるようです。

ここではDeterminate Nixのインストールを行います。公式のものにいくつかの機能が加わっており、アンインストーラも付属しているのがポイント。

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

```sh
❯ nix --version
nix (Determinate Nix 3.15.2) 2.33.1
```

## Home Manager install

このリポジトリのクローン。

```sh
git clone https://github.com/cm-kitagawa-zempei/dotfiles.git
```

Home Managerのインストール方法も複数ありますが、ここではスタンドアローン版をNix Flakesでインストールします。

[Home Manager Manual](https://nix-community.github.io/home-manager/index.xhtml#ch-nix-flakesz)

```sh
nix run home-manager -- init --switch .
```

## 設定変更の反映

設定を変更した場合は以下コマンドで反映させます。

```sh
home-manager switch --flake . -b backup
```


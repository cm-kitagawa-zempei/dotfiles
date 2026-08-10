{
  pkgs,
  hunkPackage,
  ...
}:

{
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    fzf-git-sh
    nixd
    nil
    nixfmt
    ghq
    zellij
    herdr # コーディングエージェント用マルチプレクサ（通常作業は zellij）
    gh-markdown-preview
    glow
    uv
    sqlfluff
    hunkPackage
    granted
    _1password-cli

    # Homebrew から移行した CLI ツール
    jq
    yq-go # Homebrew の yq は Go 版 (mikefarah)
    tree
    ripgrep
    sd
    ffmpeg
    duckdb
    poppler-utils # pdftotext 等の PDF CLI
    trivy
    terraform-docs
    tflint
    byobu
    pre-commit
    aws-vault
    python3Packages.cfn-lint

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
}

{ config, lib, ... }:

{
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  xdg.configFile = {
    # Zellij script
    "zellij/prompt-editor.sh" = {
      source = ../../config/zellij/prompt-editor.sh;
      executable = true;
    };

    # Helix script
    "helix/yazi-picker.sh" = {
      source = ../../config/helix/yazi-picker.sh;
      executable = true;
    };
  };

  # zellij は config.kdl を監視して既存セッションにも変更を反映するが、
  # symlink だと検知されないため実体ファイルとしてコピー配置する。
  # https://github.com/zellij-org/zellij/issues/3992
  home.activation.zellijConfigCopy = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD rm -f ${config.xdg.configHome}/zellij/config.kdl
    $DRY_RUN_CMD install -Dm644 ${../../config/zellij/config.kdl} \
      ${config.xdg.configHome}/zellij/config.kdl
  '';
}

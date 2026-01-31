{ ... }:

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
    # Zellij config
    "zellij/config.kdl".source = ../../config/zellij/config.kdl;

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
}

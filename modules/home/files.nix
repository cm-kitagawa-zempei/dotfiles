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

    # Login shell environment (Nix PATH, Homebrew, etc.)
    ".zprofile".source = ../../zsh/.zprofile;

    # Zellij config
    ".config/zellij/config.kdl".source = ../../zellij/config.kdl;

    # Zellij script
    ".config/zellij/prompt-editor.sh" = {
      source = ../../zellij/prompt-editor.sh;
      executable = true;
    };

    # Helix script
    ".config/helix/yazi-picker.sh" = {
      source = ../../.helix/yazi-picker.sh;
      executable = true;
    };
  };
}

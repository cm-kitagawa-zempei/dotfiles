{ ... }:

{
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        nerdFontsVersion = "3";
      };
      git = {
        diffRenderers = [
          {
            command = ''
              delta --dark --paging=never --line-numbers --hyperlinks \
                --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"
            '';
          }
        ];
      };
      os = {
        editPreset = "helix (hx)";
      };
    };
  };

  programs.delta = {
    enable = true;
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
}

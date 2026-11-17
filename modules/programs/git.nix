{ ... }:

let
  helixOrHx =
    choosePath: hxArg:
    ''if [ -n "$HELIX_LAZYGIT_CHOOSER" ]; then realpath ${choosePath} > "$HELIX_LAZYGIT_CHOOSER" && kill $PPID; else hx -- ${hxArg}; fi'';
in
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
        # Helix の C-l（config/helix/lazygit-picker.sh）から起動したときは
        # HELIX_LAZYGIT_CHOOSER が設定される。その場合は hx を入れ子で起動せず、
        # パスを書き出して lazygit（$PPID）を終了させ、呼び出し元の Helix に
        # 開かせる。単体で起動したときはプリセットどおり hx で開く
        edit = helixOrHx "{{filename}}" "{{filename}}";
        editAtLine = helixOrHx "{{filename}}" "{{filename}}:{{line}}";
        editAtLineAndWait = helixOrHx "{{filename}}" "{{filename}}:{{line}}";
        openDirInEditor = helixOrHx "{{dir}}" "{{dir}}";
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

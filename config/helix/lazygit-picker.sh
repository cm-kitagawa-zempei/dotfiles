#!/usr/bin/env bash
#
# lazygit-picker.sh - Helix のペイン内で lazygit を実行し、lazygit で選んだ
# ファイルを呼び出し元の Helix で開く
#
# yazi-picker.sh と同じく :insert-output で端末を lazygit に明け渡す。
# lazygit の edit 系コマンド（modules/programs/git.nix の os.edit など）は
# 環境変数 HELIX_LAZYGIT_CHOOSER が設定されているとき、hx を起動する代わりに
# パスをこのファイルへ書き出して lazygit を終了させる。
#
# Helix keybind での使い方:
#   C-l = [
#     ":write-all",
#     ":insert-output bash ~/.config/helix/lazygit-picker.sh",
#     ":reload-all",
#     ":open %sh{bash ~/.config/helix/lazygit-picker.sh --paths}",
#     ":redraw",
#   ]

set -euo pipefail

chooser_file="${XDG_CACHE_HOME:-$HOME/.cache}/helix-lazygit-chooser"

# --paths: 選択されたパスを出力する。%sh{} の展開結果は丸ごと :open の
# 1引数になるため、クォートは不要
if [[ "${1:-}" == "--paths" ]]; then
	[[ -s "$chooser_file" ]] || exit 0
	head -n 1 "$chooser_file"
	exit 0
fi

mkdir -p "$(dirname "$chooser_file")"
rm -f "$chooser_file"
# ファイル選択時は lazygit を kill で終了させるため、終了コードは無視する。
# lazygit は /dev/tty に描画するので、stdout は捨てて Helix のバッファに
# 何も挿入されないようにする
HELIX_LAZYGIT_CHOOSER="$chooser_file" lazygit > /dev/null || true
# lazygit が抜けた後、helix 向けに alternate screen と bracketed paste を復元する
printf '\033[?1049h\033[?2004h' > /dev/tty

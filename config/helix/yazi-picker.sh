#!/usr/bin/env bash
#
# yazi-picker.sh - Helix のペイン内で yazi を全画面実行するファイルピッカー
#
# lazygit (C-l) と同じ :insert-output 方式で、Helix が使っている端末ごと
# yazi に明け渡す。多重化ツール（herdr / zellij）に依存しない。
# 選択結果は固定パスの chooser ファイル経由で keybind 側の :open に渡す。
#
# Original: https://yazi-rs.github.io/docs/tips#helix
#
# Helix keybind での使い方:
#   C-y = [
#     ":insert-output bash ~/.config/helix/yazi-picker.sh '%{buffer_name}'",
#     ":open %sh{bash ~/.config/helix/yazi-picker.sh --paths}",
#     ":redraw",
#   ]

set -euo pipefail

chooser_file="${XDG_CACHE_HOME:-$HOME/.cache}/helix-yazi-chooser"

# --paths: 選択されたパスを出力する。%sh{} の展開結果は丸ごと :open の
# 1引数になる（スペースがあっても分割されない）ため、クォートは不要。
# 逆に複数選択は渡せないので先頭の1件のみ開く
if [[ "${1:-}" == "--paths" ]]; then
	[[ -s "$chooser_file" ]] || exit 0
	head -n 1 "$chooser_file"
	exit 0
fi

rm -f "$chooser_file"
yazi "${1:-.}" --chooser-file="$chooser_file" || true
# yazi が抜けた後、helix 向けに alternate screen と bracketed paste を復元する
printf '\033[?1049h\033[?2004h' > /dev/tty

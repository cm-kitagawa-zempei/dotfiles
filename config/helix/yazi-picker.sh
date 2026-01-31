#!/usr/bin/env bash
#
# yazi-picker.sh - Helix + Zellij + Yazi ファイルピッカー
#
# Originai: https://yazi-rs.github.io/docs/tips#helix-with-zellij
# 
# Usage: yazi-picker.sh <command> [start_path]
#   command:    Helixコマンド (open, vsplit, hsplit)
#   start_path: yaziの開始パス (省略時: カレントディレクトリ)
#
# Helixから呼び出す例:
#   :sh zellij run -f -- bash ~/.config/helix/yazi-picker.sh open '%{buffer_name}'

set -euo pipefail

readonly helix_command="${1:-open}"
readonly start_path="${2:-.}"

# 一時ファイルを作成し、終了時に必ず削除
chooser_file=$(mktemp)
trap 'rm -f "$chooser_file"' EXIT

# yaziをchooserモードで起動
yazi "$start_path" --chooser-file="$chooser_file"

# 選択されたパスを読み取る（末尾改行なしでも対応）
paths=""
while IFS= read -r line || [[ -n "$line" ]]; do
	paths+="$(printf "%q " "$line")"
done < "$chooser_file"

# フローティングペインを閉じる
zellij action toggle-floating-panes

# ファイルが選択されていればHelixで開く
if [[ -n "$paths" ]]; then
	zellij action write 27  # Escape
	zellij action write-chars ":${helix_command} ${paths}"
	zellij action write 13  # Enter
fi

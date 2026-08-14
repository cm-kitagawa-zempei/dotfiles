#!/bin/sh
# zellij の Alt+= / Alt+- 相当。herdr にはpaneの縮小操作が無いので、
# shrink は「隣のpaneを自分に向かって広げる」ことで代用する。
# 使い方: herdr-resize.sh grow|shrink [pane_id]  (pane_id 省略時はフォーカス中のpane)

command -v herdr >/dev/null 2>&1 || PATH="$HOME/.nix-profile/bin:$PATH"

mode="$1"
pane="$2"
amount="${HERDR_RESIZE_AMOUNT:-0.05}"

json() { python3 -c "$1" 2>/dev/null; }

if [ -z "$pane" ]; then
  pane=$(herdr pane current | json 'import json,sys;print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')
fi
[ -n "$pane" ] || exit 1

# resize を実行し、実際にレイアウトが変わったときだけ成功にする
try_resize() {
  herdr pane resize --pane "$1" --direction "$2" --amount "$amount" \
    | json 'import json,sys;sys.exit(0 if json.load(sys.stdin)["result"]["resize"]["changed"] else 1)'
}

neighbor_of() {
  herdr pane neighbor --direction "$1" --pane "$pane" \
    | json 'import json,sys;print(json.load(sys.stdin)["result"]["neighbor"].get("neighbor_pane_id") or "")'
}

case "$mode" in
  grow)
    for d in right down left up; do
      try_resize "$pane" "$d" && exit 0
    done
    ;;
  shrink)
    for pair in right:left down:up left:right up:down; do
      d=${pair%%:*}; opposite=${pair##*:}
      n=$(neighbor_of "$d")
      [ -n "$n" ] || continue
      try_resize "$n" "$opposite" && exit 0
    done
    ;;
  *)
    echo "usage: $0 grow|shrink [pane_id]" >&2
    exit 2
    ;;
esac
exit 1

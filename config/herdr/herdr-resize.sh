#!/bin/sh
# zellij 0.44 の Alt+= / Alt+-（stacked_resize 有効時の無方向リサイズ）を herdr で近似する。
# 使い方: herdr-resize.sh grow|shrink [pane_id]  (pane_id 省略時はフォーカス中のpane)
#
# zellij の挙動（tiled_panes/mod.rs stacked_resize_pane_with_id）:
#   Increase: shrink 履歴があれば取り消し(redo)。なければ 上→下→左→右 の順で
#     隣がいる最初の方向へ 30% 拡大。全方向とも不可ならフルスクリーン化。
#   Decrease: フルスクリーン中なら解除。grow 履歴があれば1段取り消し(undo)。
#     なければ同じ要領で 30% 縮小。
# herdr に無い「隣のスタック化」は省略し、フルスクリーンは zoom で代用する。
# 履歴はレイアウトのハッシュが一致する（＝他の操作が挟まっていない）場合のみ使う。
#
# herdr の resize は「隣のいない方向」を指定すると反対側の境界が動いて逆効果に
# なるため、必ず隣の存在を確認してから発行する。縮小操作も本体に無いので、
# 「隣を自分に向かって広げる」ことで代用する。

command -v herdr >/dev/null 2>&1 || PATH="$HOME/.nix-profile/bin:$PATH"

mode="$1"
pane="$2"
# zellij 本家は 30% だが大きすぎるので控えめにしている
amount="${HERDR_RESIZE_AMOUNT:-0.15}"
hist="${XDG_CACHE_HOME:-$HOME/.cache}/herdr-resize-history"

case "$mode" in
  grow|shrink) ;;
  *) echo "usage: $0 grow|shrink [pane_id]" >&2; exit 2 ;;
esac

json() { python3 -c "$1" 2>/dev/null; }

if [ -z "$pane" ]; then
  pane=$(herdr pane current | json 'import json,sys;print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')
fi
[ -n "$pane" ] || exit 1

layout() { herdr pane layout --pane "$pane"; }

layout_hash() {
  layout | json 'import json,sys,hashlib
d=json.load(sys.stdin)["result"]["layout"]
key=[[p["pane_id"],p["rect"]] for p in d["panes"]]+[[s["id"],round(s["ratio"],4)] for s in d["splits"]]
print(hashlib.md5(json.dumps(key,sort_keys=True).encode()).hexdigest())'
}

is_zoomed() {
  layout | json 'import json,sys;sys.exit(0 if json.load(sys.stdin)["result"]["layout"]["zoomed"] else 1)'
}

# resize を実行し、実際に動いた分割比の変化量を出力する。
# 限界近くでは要求量より小さくクランプされるため、undo 用に実測値を使う。
# 変化が無ければ失敗(非0)。
try_resize() {
  pre=$(layout | json 'import json,sys
d=json.load(sys.stdin)["result"]["layout"]
print(json.dumps({s["id"]:s["ratio"] for s in d["splits"]}))')
  herdr pane resize --pane "$1" --direction "$2" --amount "$3" \
    | PRE="$pre" json 'import json,sys,os
r=json.load(sys.stdin)["result"]["resize"]
pre=json.loads(os.environ["PRE"])
post={s["id"]:s["ratio"] for s in r["layout"]["splits"]}
delta=max((abs(post[k]-pre.get(k,post[k])) for k in post), default=0.0)
if not r["changed"] or delta <= 0: sys.exit(1)
print(f"{delta:.6f}")'
}

neighbor_of() {
  herdr pane neighbor --direction "$1" --pane "$pane" \
    | json 'import json,sys;print(json.load(sys.stdin)["result"]["neighbor"].get("neighbor_pane_id") or "")'
}

opposite() {
  case "$1" in
    right) echo left ;; left) echo right ;;
    down) echo up ;; up) echo down ;;
  esac
}

# 辺 $1 を外側(grow)/内側(shrink)へ量 $3 だけ動かす
move_side() {
  if [ "$2" = grow ]; then
    try_resize "$pane" "$1" "$3"
  else
    n=$(neighbor_of "$1")
    [ -n "$n" ] && try_resize "$n" "$(opposite "$1")" "$3"
  fi
}

hist_last() { [ -f "$hist" ] && tail -n 1 "$hist"; }
hist_pop() { [ -f "$hist" ] && sed -i '' -e '$d' "$hist"; }
hist_push() { # action direction amount posthash
  mkdir -p "$(dirname "$hist")"
  echo "$pane|$1|$2|$3|$4" >> "$hist"
  tail -n 50 "$hist" > "$hist.tmp" && mv "$hist.tmp" "$hist"
}

# 直前の反対操作の取り消し（undo/redo）。成立したら 0 を返す
try_revert() { # $1 = 取り消し対象の action（grow の取り消しなら grow）
  last=$(hist_last) || return 1
  [ -n "$last" ] || return 1
  h_pane=${last%%|*}; rest=${last#*|}
  h_act=${rest%%|*}; rest=${rest#*|}
  h_dir=${rest%%|*}; rest=${rest#*|}
  h_amt=${rest%%|*}; h_hash=${rest#*|}
  [ "$h_pane" = "$pane" ] && [ "$h_act" = "$1" ] || return 1
  [ "$h_hash" = "$(layout_hash)" ] || { : > "$hist"; return 1; }
  revert_mode=$([ "$1" = grow ] && echo shrink || echo grow)
  if move_side "$h_dir" "$revert_mode" "$h_amt" > /dev/null; then
    hist_pop
    return 0
  fi
  return 1
}

if [ "$mode" = grow ]; then
  is_zoomed && exit 0
  try_revert shrink && exit 0
  for d in up down left right; do
    [ -n "$(neighbor_of "$d")" ] || continue
    if delta=$(move_side "$d" grow "$amount"); then
      hist_push grow "$d" "$delta" "$(layout_hash)"
      exit 0
    fi
  done
  # どの方向にも広げられない → フルスクリーン相当
  herdr pane zoom --pane "$pane" --on > /dev/null
  exit 0
else
  if is_zoomed; then
    herdr pane zoom --pane "$pane" --off > /dev/null
    exit 0
  fi
  try_revert grow && exit 0
  for d in up down left right; do
    [ -n "$(neighbor_of "$d")" ] || continue
    if delta=$(move_side "$d" shrink "$amount"); then
      hist_push shrink "$d" "$delta" "$(layout_hash)"
      exit 0
    fi
  done
  exit 1
fi

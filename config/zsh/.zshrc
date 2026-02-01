# ============================================================================
# .zshrc - zsh設定ファイル
# ============================================================================

# ============================================================================
# 基本設定
# ============================================================================

# キーバインドのタイムアウトを延長（Ctrl+G系のキーバインド用）
# デフォルト40（0.4秒） → 100（1.0秒）に変更
export KEYTIMEOUT=100

# ============================================================================
# PATH設定
# ============================================================================

# HomebrewでインストールしたGitのパスを通す
export PATH=/usr/local/bin/git:$PATH

# Nodeのバージョンをnodebrewで管理できるようにする
export PATH=$HOME/.nodebrew/current/bin:$PATH

# PostgreSQL (libpq) のパスを通す
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Rancher Desktopのパスを通す
export PATH="$HOME/.rd/bin:$PATH"

# ============================================================================
# 補完機能設定
# ============================================================================
# compinit はHome Managerで実行済み
# ここではHomebrew用のfpath追加のみ

# Homebrewツールの補完パスを追加
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

# uv (Python package manager) の補完機能を有効化
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

# ============================================================================
# Git + fzf統合設定
# ============================================================================

# fzf-git.shを読み込み（高度なGit操作をfzfで行う）
# Nix管理に移行

# Ctrl+Gのsend-break（入力キャンセル）を無効化
# これによりfzf-gitのキーバインドが正常に動作する
bindkey -r "^G"

# ============================================================================
# カスタムGit関数（fzf統合）
# ============================================================================

# ブランチをfzfで選択してcheckout
fzf-git-branch() {
  git rev-parse HEAD > /dev/null 2>&1 || return

  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf --height 50% --ansi --tac --preview-window right:70% \
      --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

# fzfでブランチを選択してcheckout
fzf-git-checkout() {
  git rev-parse HEAD > /dev/null 2>&1 || return

  local branch
  branch=$(fzf-git-branch)
  if [[ "$branch" = "" ]]; then
    echo "No branch selected."
    return
  fi

  # リモートブランチの場合はローカルブランチとして作成
  if [[ "$branch" = 'origin/'* ]]; then
    git checkout -b "${branch#origin/}" "$branch"
  else
    git checkout "$branch"
  fi
}

# fzfでコミットを選択してshow
fzf-git-log() {
  git rev-parse HEAD > /dev/null 2>&1 || return

  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# fzfでファイルを選択してadd
fzf-git-add() {
  git rev-parse HEAD > /dev/null 2>&1 || return

  git -c color.status=always status --short |
  fzf -m --ansi --nth 2..,.. \
      --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //' |
  tr '\n' '\0' |
  xargs -0 -I {} git add {}
}

# ============================================================================
# ghq + fzf統合設定
# ============================================================================

# ghqで管理しているリポジトリをfzfで選択して移動
# キーバインド: Ctrl+]
function ghq-fzf() {
  local src=$(ghq list | fzf --preview "eza -lah --git --git-ignore --no-permissions --no-user --no-time --no-filesize --tree --level=2 --icons --color=always $(ghq root)/{} | sed \"s|$(ghq root)/[^/]*/[^/]*/||\"")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ghq-fzf
bindkey '^]' ghq-fzf

# ============================================================================
# エイリアス設定
# ============================================================================

# Python仮想環境の有効化
alias activate="source .venv/bin/activate"

# AWS CLI関連
alias awsp='aws --profile'
alias awsv='aws-vault'
alias awsvlogin='(){ open -na "Google Chrome" --args --incognito --user-data-dir=$HOME/Library/Application\ Support/Google/Chrome/aws-vault/$@ $(aws-vault login $@ --stdout) }'

# Git関連エイリアス（fzf統合）
alias gb='fzf-git-branch'          # ブランチ一覧表示
alias gch='fzf-git-checkout'       # ブランチ選択してcheckout
alias gl='fzf-git-log'             # コミット履歴をfzfで表示
alias ga='fzf-git-add'             # ファイル選択してadd

# 従来のGitコマンド
alias gd='git diff'
alias gs='git status'

# snowsql
alias snowsql=/Applications/SnowSQL.app/Contents/MacOS/snowsql

# ============================================================================
# 設定完了
# ============================================================================

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

alias npx='echo "WARNING: npx は実行しないでください" && false'
alias npm='echo "WARNING: npm は実行しないでください" && false'

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

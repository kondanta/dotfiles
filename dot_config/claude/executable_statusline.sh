#!/usr/bin/env bash
# Claude Code statusLine: two lines.
# Line 1: model | context% [bar] | token delta | cost   (identical to simple/)
# Line 2: folder | branch (links to GitHub branch if available) | +lines/-lines
#
# Standalone - just copy this file, no other dependencies needed.

set -u

input="$(cat)"
j() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

session_id=$(j '.session_id // "unknown"')
# Sanitize: session_id is interpolated into a /tmp path below.
session_id="${session_id//[^a-zA-Z0-9_-]/}"
[[ -z "$session_id" ]] && session_id="unknown"

model_name=$(j '.model.display_name // .model.id // "?"')
model_name=$(printf '%s' "$model_name" | tr -d '\000-\037\177')
cost=$(j '.cost.total_cost_usd // 0')

ctx_in=$(j '.context_window.current_usage.input_tokens // 0')
ctx_cache_w=$(j '.context_window.current_usage.cache_creation_input_tokens // 0')
ctx_cache_r=$(j '.context_window.current_usage.cache_read_input_tokens // 0')
ctx_out=$(j '.context_window.current_usage.output_tokens // 0')
ctx_size=$(j '.context_window.context_window_size // 200000')

# Per-session state for the token delta. Atomic write via tmp + mv so
# concurrent readers never see a half-written file.
state_file="/tmp/claude-statusline-${session_id}.json"
total_tokens=$(( ctx_in + ctx_cache_w + ctx_cache_r + ctx_out ))
prev_tokens=0
[[ -f "$state_file" ]] && prev_tokens=$(jq -r '.tokens // 0' "$state_file" 2>/dev/null)
state_tmp="${state_file}.tmp.$$"
if jq -n --arg t "$total_tokens" '{tokens: ($t|tonumber)}' > "$state_tmp" 2>/dev/null; then
  mv -f "$state_tmp" "$state_file" 2>/dev/null
else
  rm -f "$state_tmp" 2>/dev/null
fi

# Context bar: 20 cells, each cell = 5%.
current_ctx=$(( ctx_in + ctx_cache_w + ctx_cache_r ))
pct=$(( ctx_size > 0 ? current_ctx * 100 / ctx_size : 0 ))
(( pct > 100 )) && pct=100
filled=$(( pct / 5 ))
empty=$(( 20 - filled ))
bar=""
(( filled > 0 )) && bar+=$(printf '=%.0s' $(seq 1 $filled))
(( empty > 0 )) && bar+=$(printf -- '-%.0s' $(seq 1 $empty))

# Total tokens this turn, plus the delta since the previous render.
fmt_tokens() {
  awk -v t="$1" 'BEGIN {
    if (t >= 1000000) printf "%.1fM", t/1000000
    else if (t >= 1000) printf "%dk", int(t/1000)
    else printf "%d", t
  }'
}
token_delta=$(( total_tokens - prev_tokens ))
delta_str=""
(( token_delta > 0 )) && delta_str=" (+$(fmt_tokens "$token_delta"))"
tokens_field="$(fmt_tokens "$total_tokens") tokens${delta_str}"

cost_str=$(awk -v c="$cost" 'BEGIN { printf "$%.2f", c }')

line1=$(printf '%s | %d%% [%s] | %s | %s' "$model_name" "$pct" "$bar" "$tokens_field" "$cost_str")

# -- Line 2 extension --------------------------------------------------------

dim='\033[2m'
reset='\033[0m'

cwd=$(j '.workspace.current_dir // .cwd // ""')
[[ -d "$cwd" ]] || cwd=""
repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
if [[ -n "$repo_root" ]]; then
  repo_name="${repo_root##*/}"
  rel="${cwd#$repo_root}"; rel="${rel#/}"
  folder="${repo_name}${rel:+/$rel}"
else
  folder="${cwd/#$HOME/~}"
fi
# Strip control characters and backslashes (printf %b interprets \e as ESC)
folder=$(printf '%s' "$folder" | tr -d '\000-\037\177\\')

# Branch: prefer JSON field (no subprocess), fall back to git
branch=$(j '.worktree.branch // ""')
if [[ -z "$branch" ]] && [[ -n "$cwd" ]] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi
# Strip control characters and backslashes (printf %b interprets \e as ESC)
branch=$(printf '%s' "$branch" | tr -d '\000-\037\177\\')

# Lines changed this session
lines_added=$(j '.cost.total_lines_added // 0')
lines_removed=$(j '.cost.total_lines_removed // 0')
diff_part=""
if (( lines_added > 0 || lines_removed > 0 )); then
  diff_part="\033[32m+${lines_added}\033[0m/\033[31m-${lines_removed}\033[0m"
fi

# GitHub remote URL (convert SSH to HTTPS, strip .git)
gh_url=""
if [[ -n "$repo_root" ]]; then
  remote=$(git -C "$cwd" remote get-url origin 2>/dev/null)
  gh_url=$(printf '%s' "$remote" \
    | sed 's|git@github\.com:|https://github.com/|' \
    | sed 's|\.git$||')
  # Only keep if it's actually a GitHub URL
  [[ "$gh_url" != https://github.com/* ]] && gh_url=""
  gh_url=$(printf '%s' "$gh_url" | tr -d '\000-\037\177\\')
fi

sep="${dim} | ${reset}"
line2="[dir] ${folder}"
if [[ -n "$branch" ]]; then
  if [[ -n "$gh_url" ]]; then
    line2+="${sep}\e]8;;${gh_url}/tree/${branch}\a[branch] ${branch}\e]8;;\a"
  else
    line2+="${sep}[branch] ${branch}"
  fi
fi
[[ -n "$diff_part" ]] && line2+="${sep}${diff_part}"

printf '%s\n' "$line1"
printf '%b' "$line2"

#!/bin/sh
# Claude Code statusLine command.
# Receives JSON on stdin; emits a single status line.
# Layout (segments shown only when applicable, separated by " │ "):
#   [dir] [branch+worktree-icon] [@agent] [model] [effort] [ctx]
#   [tokens in/out] [+added -removed] [cost] [duration] [5h%] [7d%] [version]
# All segments left-aligned with " │ " separators. Claude Code reserves the
# right side of this row for its own notifications, so we don't right-align.
# Nerd Font glyphs (single-width, monochrome):
#   U+F07B  nf-fa-folder          dir
#   U+E0A0  nf-pl-branch          branch (Powerline)
#   U+F126  nf-fa-code_fork       worktree
#   U+F2BD  nf-fa-user_o          agent
#   U+F0D0  nf-fa-magic           model
#   U+F085  nf-fa-cogs            effort
#   U+F2DB  nf-fa-microchip       context
#   U+F062  nf-fa-arrow_up        input tokens
#   U+F063  nf-fa-arrow_down      output tokens
#   U+F017  nf-fa-clock_o         duration
#   U+F252  nf-fa-hourglass_end   rate limit
#   U+F02B  nf-fa-tag             version
#   U+F401  nf-oct-repo           git repo

input=$(cat)

# --- Raw values ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
repo_name=$(echo "$input" | jq -r '.workspace.repo.name // empty')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty')
original_cwd=$(echo "$input" | jq -r '.worktree.original_cwd // empty')
# Prefer the git repo name (stable across worktrees), then project_dir,
# then the pre-worktree cwd, finally the current cwd basename.
if [ -n "$repo_name" ]; then
  dir="$repo_name"
  dir_from_repo=1
elif [ -n "$project_dir" ]; then
  dir=$(basename "$project_dir")
  dir_from_repo=""
elif [ -n "$original_cwd" ]; then
  dir=$(basename "$original_cwd")
  dir_from_repo=""
else
  dir=$(basename "$cwd")
  dir_from_repo=""
fi
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
in_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
out_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')
rl_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
effort_level=$(echo "$input" | jq -r '.effort.level // empty')
agent_name=$(echo "$input" | jq -r '.agent.name // empty')
worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')
version=$(echo "$input" | jq -r '.version // empty')

# --- Git branch ---
# In a worktree, .workspace.git_worktree is the worktree slug, not the branch
# name. Prefer .worktree.branch (the worktree's actual HEAD) when set.
if [ -n "$worktree_name" ]; then
  git_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
else
  git_branch=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
fi
if [ -z "$git_branch" ]; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

# --- Format duration: days/hours/minutes, hide leading zero segments ---
# Fallback to seconds only when <1 minute, so new sessions show "Xs" not "0m"
duration_str=""
if [ -n "$duration_ms" ] && [ "$duration_ms" != "null" ]; then
  total_s=$(echo "$duration_ms" | awk '{printf "%d", $1/1000}')
  days=$(( total_s / 86400 ))
  hours=$(( (total_s % 86400) / 3600 ))
  mins=$(( (total_s % 3600) / 60 ))
  secs=$(( total_s % 60 ))

  if [ "$days" -gt 0 ]; then
    duration_str="${days}d ${hours}h ${mins}m"
  elif [ "$hours" -gt 0 ]; then
    duration_str="${hours}h ${mins}m"
  elif [ "$mins" -gt 0 ]; then
    duration_str="${mins}m"
  else
    duration_str="${secs}s"
  fi
fi

# --- Format cost ---
cost_str=""
if [ -n "$total_cost" ] && [ "$total_cost" != "null" ]; then
  cost_str=$(printf '$%.2f' "$total_cost")
fi

# --- Context percentage (plain NN%) ---
ctx_str=""
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  pct_int=$(echo "$used_pct" | awk '{printf "%d", $1 + 0.5}')
  ctx_str="${pct_int}% ctx"
fi

# --- ANSI colours: muted/professional palette ---
RESET='\033[0m'
DIM='\033[38;5;240m'       # mid-grey      — separators, labels, duration
ACCENT='\033[38;5;109m'    # muted slate   — dir / branch
MODEL='\033[38;5;246m'     # light grey    — model name
COST='\033[38;5;179m'      # warm amber    — cost (single accent)
GREEN='\033[38;5;108m'     # muted sage    — lines added
RED='\033[38;5;167m'       # muted rust    — lines removed / alert
WARN='\033[38;5;179m'      # warm amber    — mid-threshold warning
INFO='\033[38;5;73m'       # muted teal    — low-usage informational
TOK_IN_CLR='\033[38;5;110m'   # sky blue   — incoming tokens
TOK_OUT_CLR='\033[38;5;139m'  # dusty mauve — outgoing tokens

SEP="${DIM} │ ${RESET}"

# --- Nerd Font glyphs (single-width, inherit ANSI colour) ---
ICON_DIR=''        # U+F07B  nf-fa-folder
ICON_BRANCH=''    # U+E0A0  nf-pl-branch (Powerline)
ICON_CLOCK=''     # U+F017  nf-fa-clock_o
ICON_WORKTREE=''  # U+F126  nf-fa-code_fork
ICON_AGENT=''     # U+F2BD  nf-fa-user_o
ICON_MODEL=''     # U+F0D0  nf-fa-magic
ICON_EFFORT=''    # U+F085  nf-fa-cogs
ICON_CTX=''       # U+F2DB  nf-fa-microchip
ICON_TOK_IN=''    # U+F062  nf-fa-arrow_up
ICON_TOK_OUT=''   # U+F063  nf-fa-arrow_down
ICON_RL=''        # U+F252  nf-fa-hourglass_end
ICON_VERSION=''   # U+F02B  nf-fa-tag
ICON_REPO=''      # U+F401  nf-oct-repo

# --- Pick colour for a rate-limit % : <50% dim, 50-80% warn, >80% alert ---
pct_colour() {
  pct_int=$(echo "$1" | awk '{printf "%d", $1 + 0.5}')
  if [ "$pct_int" -gt 80 ]; then
    printf '%s' "$RED"
  elif [ "$pct_int" -ge 50 ]; then
    printf '%s' "$WARN"
  else
    printf '%s' "$DIM"
  fi
}

# --- Pick colour for context % : <70% info, 70-90% warn, >90% alert ---
# Context use is naturally high during work, so thresholds are relaxed
# vs rate limits, and the low band uses INFO (visible) not DIM.
ctx_colour() {
  pct_int=$(echo "$1" | awk '{printf "%d", $1 + 0.5}')
  if [ "$pct_int" -gt 90 ]; then
    printf '%s' "$RED"
  elif [ "$pct_int" -ge 70 ]; then
    printf '%s' "$WARN"
  else
    printf '%s' "$INFO"
  fi
}

# --- Format rate-limit segment: " <label> NN%" coloured by threshold ---
rl_segment() {
  label="$1"; pct="$2"
  [ -z "$pct" ] || [ "$pct" = "null" ] && return 1
  c=$(pct_colour "$pct")
  pct_int=$(echo "$pct" | awk '{printf "%d", $1 + 0.5}')
  printf '%s%s %s %d%%%s' "$c" "$ICON_RL" "$label" "$pct_int" "$RESET"
}

# --- Format a token count: 1234 -> 1.2k, 1500000 -> 1.5M, <1000 -> raw ---
fmt_tokens() {
  [ -z "$1" ] || [ "$1" = "null" ] && return 1
  echo "$1" | awk '{
    if ($1 >= 1000000) printf "%.1fM", $1/1000000;
    else if ($1 >= 10000) printf "%.0fk", $1/1000;
    else if ($1 >= 1000) printf "%.1fk", $1/1000;
    else printf "%d", $1;
  }'
}

# --- Append a colourised segment to $line, with " │ " separator ---
line=""
append() {
  if [ -z "$line" ]; then
    line="$1"
  else
    line="${line}${SEP}$1"
  fi
}

if [ -n "$dir_from_repo" ]; then
  append "${ACCENT}${ICON_REPO} ${dir}${RESET}"
else
  append "${ACCENT}${ICON_DIR} ${dir}${RESET}"
fi
if [ -n "$git_branch" ]; then
  branch_seg="${ACCENT}${ICON_BRANCH} ${git_branch}${RESET}"
  [ -n "$worktree_name" ] && branch_seg="${branch_seg} ${WARN}${ICON_WORKTREE}${RESET}"
  append "$branch_seg"
fi
[ -n "$agent_name" ]    && append "${WARN}${ICON_AGENT} ${agent_name}${RESET}"
[ -n "$model" ]         && append "${MODEL}${ICON_MODEL} ${model}${RESET}"
case "$effort_level" in
  ""|default) ;;
  high)  append "${WARN}${ICON_EFFORT} ${effort_level}${RESET}" ;;
  *)     append "${DIM}${ICON_EFFORT} ${effort_level}${RESET}" ;;
esac
if [ -n "$ctx_str" ]; then
  ctx_clr=$(ctx_colour "$used_pct")
  append "${ctx_clr}${ICON_CTX} ${ctx_str}${RESET}"
fi
in_fmt=$(fmt_tokens "$in_tokens") || in_fmt=""
out_fmt=$(fmt_tokens "$out_tokens") || out_fmt=""
if [ -n "$in_fmt" ] || [ -n "$out_fmt" ]; then
  tok_seg=""
  [ -n "$in_fmt" ]  && tok_seg="${TOK_IN_CLR}${ICON_TOK_IN} ${in_fmt}${RESET}"
  [ -n "$out_fmt" ] && tok_seg="${tok_seg:+$tok_seg }${TOK_OUT_CLR}${ICON_TOK_OUT} ${out_fmt}${RESET}"
  append "$tok_seg"
fi
if [ -n "$lines_added" ] && [ -n "$lines_removed" ] \
   && { [ "$lines_added" -gt 0 ] 2>/dev/null || [ "$lines_removed" -gt 0 ] 2>/dev/null; }; then
  append "${GREEN}+${lines_added}${RESET} ${RED}-${lines_removed}${RESET}"
fi
[ -n "$cost_str" ]      && append "${COST}${cost_str}${RESET}"
[ -n "$duration_str" ]  && append "${DIM}${ICON_CLOCK} ${duration_str}${RESET}"
seg=$(rl_segment "5h" "$rl_5h") && append "$seg"
seg=$(rl_segment "7d" "$rl_7d") && append "$seg"
[ -n "$version" ]       && append "${DIM}${ICON_VERSION} ${version}${RESET}"

printf "%b\n" "$line"

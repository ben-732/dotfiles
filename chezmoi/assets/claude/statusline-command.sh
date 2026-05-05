#!/bin/sh
# Claude Code statusLine command.
# Receives JSON on stdin; emits a single status line.
# Layout: LEFT [ dir   branch  model]   RIGHT [ctx%  cost   duration]
# Nerd Font glyphs (single-width, monochrome):
#   U+F07B  nf-fa-folder          folder
#   U+E0A0  nf-pl-branch          git branch (Powerline)
#   U+F017  nf-fa-clock_o         clock

input=$(cat)

# --- Raw values ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')

# --- Terminal width: JSON field > $COLUMNS > tput ---
term_width=$(echo "$input" | jq -r '.terminal.width // empty' 2>/dev/null)
if [ -z "$term_width" ] || [ "$term_width" = "null" ]; then
  term_width="${COLUMNS:-}"
fi
if [ -z "$term_width" ]; then
  term_width=$(tput cols 2>/dev/null)
fi
if [ -z "$term_width" ] || [ "$term_width" -le 0 ] 2>/dev/null; then
  term_width=120
fi

# --- Git branch ---
git_branch=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
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

SEP="${DIM} │ ${RESET}"

# --- Nerd Font glyphs (single-width, inherit ANSI colour) ---
ICON_DIR=''        # U+F07B  nf-fa-folder
ICON_BRANCH=''    # U+E0A0  nf-pl-branch (Powerline)
ICON_CLOCK=''     # U+F017  nf-fa-clock_o

# --- Build left group ---
left=""
left="${left}${ACCENT}${ICON_DIR} ${dir}${RESET}"
if [ -n "$git_branch" ]; then
  left="${left}${DIM}  ${RESET}${ACCENT}${ICON_BRANCH} ${git_branch}${RESET}"
fi
left="${left}${SEP}${MODEL}${model}${RESET}"

# --- Build right group ---
right=""
if [ -n "$ctx_str" ]; then
  right="${right}${DIM}${ctx_str}${RESET}"
fi
if [ -n "$cost_str" ]; then
  [ -n "$right" ] && right="${right}${SEP}"
  right="${right}${COST}${cost_str}${RESET}"
fi
if [ -n "$duration_str" ]; then
  [ -n "$right" ] && right="${right}${SEP}"
  right="${right}${DIM}${ICON_CLOCK} ${duration_str}${RESET}"
fi

# --- Strip ANSI escapes to measure visible length ---
# Uses sed to remove ESC[...m sequences, then wc -m for char count
strip_ansi() {
  printf '%b' "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

left_plain=$(strip_ansi "$left")
right_plain=$(strip_ansi "$right")
left_len=$(printf '%s' "$left_plain" | wc -m | tr -d ' ')
right_len=$(printf '%s' "$right_plain" | wc -m | tr -d ' ')

# --- Compute padding ---
pad=$(( term_width - left_len - right_len ))
if [ "$pad" -lt 1 ]; then
  pad=1
fi
padding=$(printf '%*s' "$pad" '')

# --- Emit ---
if [ -n "$right" ]; then
  printf "%b%s%b\n" "$left" "$padding" "$right"
else
  printf "%b\n" "$left"
fi

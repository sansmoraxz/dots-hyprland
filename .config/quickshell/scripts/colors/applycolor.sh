#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/quickshell"
CACHE_DIR="$XDG_CACHE_HOME/quickshell"
STATE_DIR="$XDG_STATE_HOME/quickshell"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

term_alpha=100 #Set this to < 100 make all your terminals transparent
# sleep 0 # idk i wanted some delay or colors dont get applied properly
if [ ! -d "$STATE_DIR"/user/generated ]; then
  mkdir -p "$STATE_DIR"/user/generated
fi
cd "$CONFIG_DIR" || exit

colornames=''
colorstrings=''
colorlist=()
colorvalues=()

colornames=$(cat $STATE_DIR/user/generated/material_colors.scss | cut -d: -f1)
colorstrings=$(cat $STATE_DIR/user/generated/material_colors.scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
IFS=$'\n'
colorlist=($colornames)     # Array of color names
colorvalues=($colorstrings) # Array of color values

apply_term() {
  # Check if terminal escape sequence template exists
  if [ ! -f "$CONFIG_DIR"/scripts/terminal/sequences.txt ]; then
    echo "Template file not found for Terminal. Skipping that."
    return
  fi
  # Copy template
  mkdir -p "$STATE_DIR"/user/generated/terminal
  cp "$CONFIG_DIR"/scripts/terminal/sequences.txt "$STATE_DIR"/user/generated/terminal/sequences.txt
  # Apply colors
  for i in "${!colorlist[@]}"; do
    sed -i "s/${colorlist[$i]} #/${colorvalues[$i]#\#}/g" "$STATE_DIR"/user/generated/terminal/sequences.txt
  done

  sed -i "s/\$alpha/$term_alpha/g" "$STATE_DIR/user/generated/terminal/sequences.txt"

  # List of known "pure" terminal emulator names (case-insensitive match)
  PURE_TERMINALS="kitty|foot|gnome-terminal|alacritty|xterm|konsole|rxvt|wezterm|uxterm"

  for pts in /dev/pts/[0-9]*; do
      ptsnum=$(basename "$pts")

      # Get PID(s) associated with this TTY
      pids=$(ps -t "pts/$ptsnum" -o pid= | awk '{print $1}')

      for pid in $pids; do
          # Walk the process tree upward from this PID
          current=$pid
          while [ -n "$current" ] && [ "$current" -ne 1 ]; do
              # Get command name for this PID
              cmd=$(ps -p "$current" -o comm= 2>/dev/null)

              # Check if it matches a pure terminal
              if echo "$cmd" | grep -Eiq "$PURE_TERMINALS"; then
                  echo "Found pure terminal '$cmd' on $pts — sending escape sequences"
                  {
                  cat "$STATE_DIR"/user/generated/terminal/sequences.txt >"$pts"
                  } & disown || true
                  break
              fi

              # Move to parent PID
              current=$(ps -p "$current" -o ppid= 2>/dev/null | awk '{print $1}')
          done
      done
  done
}

apply_qt() {
  sh "$CONFIG_DIR/scripts/kvantum/materialQT.sh"          # generate kvantum theme
  python "$CONFIG_DIR/scripts/kvantum/changeAdwColors.py" # apply config colors
}

apply_qt &
apply_term &

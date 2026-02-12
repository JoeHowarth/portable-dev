#!/usr/bin/env bash
# Portable tmux config — iTerm2-ish keybindings for any machine
set -euo pipefail

TMUX_CONF="$HOME/.tmux.conf"

if [ -f "$TMUX_CONF" ]; then
  cp "$TMUX_CONF" "$TMUX_CONF.bak.$(date +%s)"
  echo "Backed up existing .tmux.conf"
fi

cat > "$TMUX_CONF" << 'CONF'
# ──────────────────────────────────────────────
# Portable tmux config — iTerm2 training wheels
# ──────────────────────────────────────────────

# Prefix: Ctrl-a (easier to reach than Ctrl-b)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# ── Splits (like iTerm2 Cmd+D / Cmd+Shift+D) ──
# Alt-d = vertical split (side by side)
# Alt-shift-d = horizontal split (top/bottom)
# Both open in the current directory
bind -n M-d split-window -h -c "#{pane_current_path}"
bind -n M-D split-window -v -c "#{pane_current_path}"

# Prefix + | and - as memorable alternatives
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# ── Pane navigation (like iTerm2 Cmd+Option+Arrow) ──
# Alt-arrow to move between panes — no prefix needed
bind -n M-Left  select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up    select-pane -U
bind -n M-Down  select-pane -D

# Alt-h/j/k/l for vim-style pane nav
bind -n M-h select-pane -L
bind -n M-j select-pane -D
bind -n M-k select-pane -U
bind -n M-l select-pane -R

# ── Pane resizing ──
# Alt-shift-arrow to resize
bind -n M-S-Left  resize-pane -L 2
bind -n M-S-Right resize-pane -R 2
bind -n M-S-Up    resize-pane -U 2
bind -n M-S-Down  resize-pane -D 2

# ── Windows (like iTerm2 tabs) ──
# Alt-t = new window, Alt-w = close pane (with confirm)
bind -n M-t new-window -c "#{pane_current_path}"
bind -n M-w confirm-before -p "close pane? (y/n)" kill-pane

# Alt-1..9 to jump to window by number
bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3
bind -n M-4 select-window -t 4
bind -n M-5 select-window -t 5
bind -n M-6 select-window -t 6
bind -n M-7 select-window -t 7
bind -n M-8 select-window -t 8
bind -n M-9 select-window -t 9

# Alt-[ / Alt-] to cycle windows (like Cmd+Shift+[ ] in iTerm2)
bind -n M-[ previous-window
bind -n M-] next-window

# ── Quality of life ──
# Start window/pane numbering at 1 (matches keyboard layout)
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on

# Mouse support (scroll, click to select pane, resize by drag)
set -g mouse on

# Longer scrollback
set -g history-limit 50000

# Reduce escape delay (feels snappier, important for vim/neovim)
set -sg escape-time 10

# True color support
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# ── Copy mode (like iTerm2 selection) ──
# Enter copy mode with prefix + [ (default), then:
#   v to start selection, y to yank
setw -g mode-keys vi
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-selection-and-cancel

# ── Status bar — clean and informative ──
set -g status-style "bg=colour235,fg=colour248"
set -g status-left "#[fg=colour214,bold] #S "
set -g status-right "#[fg=colour248]%H:%M #[fg=colour214]#h "
set -g status-left-length 30
setw -g window-status-format " #I:#W "
setw -g window-status-current-format "#[fg=colour214,bold] #I:#W "

# Active pane border
set -g pane-active-border-style "fg=colour214"
set -g pane-border-style "fg=colour238"

# ── Reload config ──
bind r source-file ~/.tmux.conf \; display "Config reloaded"
CONF

echo ""
echo "tmux config installed to ~/.tmux.conf"
echo ""
echo "Quick reference:"
echo "  Prefix:          Ctrl-a"
echo ""
echo "  Splits:          Alt-d (vertical)  Alt-Shift-d (horizontal)"
echo "  Navigate panes:  Alt-arrow  or  Alt-h/j/k/l"
echo "  Resize panes:    Alt-Shift-arrow"
echo ""
echo "  New window:      Alt-t"
echo "  Close pane:      Alt-w"
echo "  Switch window:   Alt-1..9  or  Alt-[ / Alt-]"
echo ""
echo "  Copy mode:       Ctrl-a [  (then v to select, y to yank)"
echo "  Reload config:   Ctrl-a r"
echo ""

# Reload if tmux is running
if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null 2>&1; then
  tmux source-file "$TMUX_CONF" 2>/dev/null && echo "Live-reloaded running tmux." || true
fi

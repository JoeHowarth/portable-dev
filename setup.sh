#!/usr/bin/env bash
# Bootstrap a dev environment on any machine
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/JoeHowarth/portable-dev/main/setup.sh | bash
#   curl ... | bash -s -- --tmux-only
#   curl ... | bash -s -- --nvim-only
#   curl ... | bash -s -- --ssh-wrapper  (local machine only — installs the ssh auto-bootstrap)
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/JoeHowarth/portable-dev/main"

run_tmux() {
  echo "=== Setting up tmux ==="
  bash <(curl -fsSL "$REPO_URL/tmux/setup.sh")
}

run_nvim() {
  echo "=== Setting up neovim ==="
  bash <(curl -fsSL "$REPO_URL/nvim/setup.sh")
}

run_ssh_wrapper() {
  echo "=== Setting up ssh wrapper ==="
  local wrapper_dir="$HOME/.portable-dev"
  mkdir -p "$wrapper_dir"
  curl -fsSL "$REPO_URL/shell/ssh-wrapper.sh" -o "$wrapper_dir/ssh-wrapper.sh"

  local source_line='source "$HOME/.portable-dev/ssh-wrapper.sh"'

  # Add to .bashrc and/or .zshrc if not already present
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] || [[ "$rc" == *zshrc* && "$SHELL" == *zsh* ]] || [[ "$rc" == *bashrc* && "$SHELL" == *bash* ]]; then
      if ! grep -qF "portable-dev/ssh-wrapper" "$rc" 2>/dev/null; then
        echo "" >> "$rc"
        echo "# Auto-bootstrap portable-dev on ssh connections" >> "$rc"
        echo "$source_line" >> "$rc"
        echo "Added ssh wrapper to $rc"
      else
        echo "ssh wrapper already in $rc"
      fi
    fi
  done

  echo ""
  echo "ssh wrapper installed. New ssh connections will auto-bootstrap portable-dev."
  echo "Restart your shell or run: source ~/.portable-dev/ssh-wrapper.sh"
}

case "${1:-all}" in
  --tmux-only)       run_tmux ;;
  --nvim-only)       run_nvim ;;
  --ssh-wrapper)     run_ssh_wrapper ;;
  all|*)
    run_tmux
    echo ""
    run_nvim
    ;;
esac

echo ""
echo "Done! You may need to restart your shell or run: source ~/.bashrc"

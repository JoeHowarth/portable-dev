#!/usr/bin/env bash
# Bootstrap a dev environment on any machine
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/JoeHowarth/portable-dev/main/setup.sh | bash
#   curl ... | bash -s -- --tmux-only
#   curl ... | bash -s -- --nvim-only
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

case "${1:-all}" in
  --tmux-only) run_tmux ;;
  --nvim-only) run_nvim ;;
  all|*)
    run_tmux
    echo ""
    run_nvim
    ;;
esac

echo ""
echo "Done! You may need to restart your shell or run: source ~/.bashrc"

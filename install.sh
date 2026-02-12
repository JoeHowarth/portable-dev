#!/usr/bin/env bash
# Local machine installer for portable-dev
# Usage:
#   git clone https://github.com/JoeHowarth/portable-dev ~/tools/portable-dev
#   cd ~/tools/portable-dev && ./install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect shell config file
if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == */zsh ]]; then
  SHELL_RC="$HOME/.zshrc"
else
  SHELL_RC="$HOME/.bashrc"
fi

echo "=== portable-dev installer ==="
echo "Shell detected: $SHELL_RC"
echo ""

# ── tmux ──
echo "--- tmux config ---"
bash "$SCRIPT_DIR/tmux/setup.sh"
echo ""

# ── neovim ──
echo "--- neovim ---"
read -p "Install neovim to userspace? [Y/n] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  bash "$SCRIPT_DIR/nvim/setup.sh"
else
  echo "Skipped neovim."
fi
echo ""

# ── ssh wrapper ──
echo "--- ssh wrapper ---"
echo "This overrides 'ssh' so that interactive connections automatically"
echo "bootstrap portable-dev on the remote host and attach to tmux."
echo ""

SOURCE_LINE="source \"$SCRIPT_DIR/shell/ssh-wrapper.sh\""

if grep -qF "portable-dev" "$SHELL_RC" 2>/dev/null; then
  echo "ssh wrapper already configured in $SHELL_RC"
else
  read -p "Add ssh wrapper to $SHELL_RC? [Y/n] " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "" >> "$SHELL_RC"
    echo "# portable-dev: auto-bootstrap on ssh connections" >> "$SHELL_RC"
    echo "$SOURCE_LINE" >> "$SHELL_RC"
    echo "Added to $SHELL_RC"
  else
    echo "Skipped. To add manually:"
    echo "  $SOURCE_LINE"
  fi
fi

echo ""
echo "=== Installation complete ==="
echo ""
echo "Reload your shell or run:"
echo "  source $SHELL_RC"
echo ""
echo "Then ssh to any machine and portable-dev will auto-install on first connect."

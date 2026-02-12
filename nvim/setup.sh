#!/bin/bash
# Install Neovim in userspace without sudo
set -euo pipefail

INSTALL_DIR="$HOME/.local/nvim"
NVIM_VERSION="v0.10.2"
ARCH="$(uname -m)"
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

# Ensure ~/.local/bin exists and is in PATH
mkdir -p "$HOME/.local/bin"
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    export PATH="$HOME/.local/bin:$PATH"
fi

echo "Installing Neovim ${NVIM_VERSION} for ${OS}-${ARCH}..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

curl -LO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-${OS}64.tar.gz"
tar xzf "nvim-${OS}64.tar.gz" --strip-components=1
rm "nvim-${OS}64.tar.gz"

ln -sf "$INSTALL_DIR/bin/nvim" "$HOME/.local/bin/nvim"

# Minimal config
mkdir -p "$HOME/.config/nvim"
cat > "$HOME/.config/nvim/init.lua" << 'EOF'
-- Minimal config for remote servers

-- Support yank to clipboard over ssh
local is_tmux_session = vim.env.TERM_PROGRAM == "tmux"
if vim.env.SSH_TTY and not is_tmux_session then
   local function paste()
     return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
   end
   local osc52 = require("vim.ui.clipboard.osc52")
   vim.g.clipboard = {
     name = "OSC 52",
     copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
   }
end

vim.opt.number = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Basic keymaps
vim.api.nvim_set_keymap('i', 'fd', '<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<space>', '<nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic file navigation
vim.api.nvim_set_keymap('n', '<leader>e', ':Ex<CR>', { noremap = true, silent = true })
EOF

# Create system-wide links if sudo is available
if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    echo "Sudo access available, creating system-wide links..."
    sudo ln -sf "$INSTALL_DIR/bin/nvim" /usr/local/bin/nvim
    sudo mkdir -p /root/.config
    sudo ln -sf "$HOME/.config/nvim" /root/.config/nvim
    echo "System-wide links created."
else
    echo "Note: No sudo access. Neovim installed for current user only."
fi

echo ""
echo "Neovim installed to $INSTALL_DIR"
echo "Symlink at ~/.local/bin/nvim"
echo "Config at ~/.config/nvim/init.lua"
echo "Run 'source ~/.bashrc' or start a new shell to use nvim"

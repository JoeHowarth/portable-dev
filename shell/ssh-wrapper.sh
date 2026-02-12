# portable-dev ssh wrapper
# Source this in your .bashrc / .zshrc:
#   source ~/tools/portable-dev/shell/ssh-wrapper.sh
#
# On interactive ssh connections, automatically bootstraps portable-dev
# on the remote host if it hasn't been set up yet. Non-interactive ssh
# (git, scp, pipes, remote commands) passes through untouched.

ssh() {
  # Fast path: not a terminal — pass through (git, scp, scripts, etc.)
  if [ ! -t 0 ] || [ ! -t 1 ]; then
    command ssh "$@"
    return
  fi

  # Detect if a remote command was given by parsing ssh args
  # ssh [options] destination [command...]
  local destination=""
  local has_remote_cmd=false
  local skip_next=false

  for arg in "$@"; do
    if $skip_next; then
      skip_next=false
      continue
    fi
    case "$arg" in
      -[bcDEeFIiJLlmOopQRSWw]) skip_next=true ;;  # flags that consume next arg
      -*)  ;;                                       # other flags
      *)
        if [ -z "$destination" ]; then
          destination="$arg"
        else
          has_remote_cmd=true
          break
        fi
        ;;
    esac
  done

  # If there's an explicit remote command, pass through
  if $has_remote_cmd; then
    command ssh "$@"
    return
  fi

  # Interactive connection — check marker, bootstrap if needed
  command ssh -t "$@" '
    if [ ! -f "$HOME/.portable-dev-ok" ]; then
      echo "Setting up portable-dev..."
      if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://raw.githubusercontent.com/JoeHowarth/portable-dev/main/setup.sh | bash && touch "$HOME/.portable-dev-ok"
      elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://raw.githubusercontent.com/JoeHowarth/portable-dev/main/setup.sh | bash && touch "$HOME/.portable-dev-ok"
      else
        echo "Warning: no curl or wget, skipping portable-dev bootstrap"
      fi
    fi
    if command -v tmux >/dev/null 2>&1; then
      exec tmux new-session -A -s main
    else
      exec $SHELL -l
    fi
  '
}

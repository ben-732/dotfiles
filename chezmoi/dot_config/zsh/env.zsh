export EDITOR=nvim

# Node Version Manager setup
export NVM_DIR="$HOME/.nvm"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export ANTHROPIC_MODEL='sonnet'
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7[1m]'

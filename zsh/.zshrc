# Machine specific configs
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

_ZSH_DIR="$HOME/.zsh"

export PATH="/opt/homebrew/bin:$PATH"

source $_ZSH_DIR/aliases.zsh
source $_ZSH_DIR/functions.zsh

eval "$(oh-my-posh init zsh --config $_ZSH_DIR/poshthemes/me.omp.json)";


# Load work config conditionally
[[ -f $_ZSH_DIR/work.zsh ]] && source $_ZSH_DIR/work.zsh || true

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" || true

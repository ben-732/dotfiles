# Machine specific configs
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

export PATH="/opt/homebrew/bin:$PATH"

source ~/.zsh/aliases.zsh
source ~/.zsh/functions.zsh

eval "$(oh-my-posh init zsh --config ~/.zsh/poshthemes/me.omp.json)";


# Load work config conditionally
[[ -f ~/.zsh/work.zsh ]] && source ~/.zsh/work.zsh

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 

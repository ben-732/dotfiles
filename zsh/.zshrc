

eval "$(oh-my-posh init zsh --config ~/.zsh/poshthemes/me.omp.json)";

source ~/.zsh/aliases.zsh
source ~/.zsh/functions.zsh

# Machine specific configs
[[ -f ~/.zsh/zshrc.local ]] && source ~/.zsh/zshrc.local

# Load work config conditionally
[[ -f ~/.zsh/work.zsh ]] && source ~/.zsh/work.zsh

# pnpm
export PNPM_HOME="/Users/work/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

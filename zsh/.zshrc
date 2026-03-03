_ZSH_DIR="$HOME/me/dotfiles/zsh/.zsh"


source $_ZSH_DIR/aliases.zsh
source $_ZSH_DIR/functions.zsh


if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $_ZSH_DIR/poshthemes/me.omp.json)";
fi


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

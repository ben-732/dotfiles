alias bp="code $HOME/.zshrc"

alias gti="git"
alias pm="pnpm"

# If Eza installed register aliases + help function
if command -v eza &> /dev/null; then 
  alias ls='eza'
  alias l='eza -lbF --git'
  alias ll='eza -lbGF --git'
  alias llm='eza -lbGd --git --sort=modified'
  alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale'
  alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale'

  # specialty views
  alias lS='eza -1'
  alias lt='eza --tree --level=2'
  alias l.="eza -a | grep -E '^\.'"

  lsh ()
  {
    echo "eza Aliases"
    echo "------------"
    echo "ls   : List files using eza (modern replacement for ls)."
    echo "l    : Long list view with file sizes, type indicators, and git status."
    echo "ll   : Long list view including git status and grouped directories."
    echo "llm  : Long list view sorted by last modified time (directories grouped)."
    echo "la   : Detailed long list including hidden files, header, icons, git info,"
    echo "       sorted by modification time with long ISO timestamps and color scale."
    echo "lx   : Same as 'la' but also shows extended attributes and file metadata."
    echo
    echo "Specialty Views"
    echo "---------------"
    echo "lS   : Single-column output (one entry per line)."
    echo "lt   : Tree view of directories, limited to 2 levels deep."
    echo "l.   : Show only hidden files (names starting with a dot)."
  }
fi 

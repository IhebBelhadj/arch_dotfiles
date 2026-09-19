#  Startup 
# Commands on startup (before the prompt is shown)
# This is a good place to load graphic/ascii art, display system information, etc.

# fastfetch --logo-type kitty
# fastfetch.sh

#  Aliases 
# Override aliases here or in '~/.zshrc' (already set in .zshenv)

# # Helpful aliases
# alias c='clear'                                                        # clear terminal
# alias l='eza -lh --icons=auto'                                         # long list
# alias ls='eza -1 --icons=auto'                                         # short list
# alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
# alias ld='eza -lhD --icons=auto'                                       # long list dirs
# alias lt='eza --icons=auto --tree'                                     # list folder as tree
# alias un='$aurhelper -Rns'                                             # uninstall package
# alias up='$aurhelper -Syu'                                             # update system/package/aur
# alias pl='$aurhelper -Qs'                                              # list installed package
# alias pa='$aurhelper -Ss'                                              # list available package
# alias pc='$aurhelper -Sc'                                              # remove unused cache
# alias po='$aurhelper -Qtdq | $aurhelper -Rns -'                        # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
# alias vc='code'                                                        # gui code editor
# alias fastfetch='fastfetch --logo-type kitty'

# # Directory navigation shortcuts
# alias ..='cd ..'
# alias ...='cd ../..'
# alias .3='cd ../../..'
# alias .4='cd ../../../..'
# alias .5='cd ../../../../..'

# # Always mkdir a path (this doesn't inhibit functionality to make a single dir)
# alias mkdir='mkdir -p'

#  Plugins 
# manually add your oh-my-zsh plugins here
plugins=(
    "sudo"
    "git"                     # (default)
    "zsh-autosuggestions"     # (default)
    "zsh-syntax-highlighting" # (default)
    # "zsh-completions"         # (default)
)

#  oh-my-zsh custom plugin path 
# HyDE sets ZSH=/usr/share/oh-my-zsh and hardcodes zsh-256color into its plugin
# list, but that plugin only exists under ~/.oh-my-zsh. Point ZSH_CUSTOM at a
# dedicated dir holding just that plugin, so the system copies of
# zsh-autosuggestions / zsh-syntax-highlighting are not shadowed.
export ZSH_CUSTOM="$ZDOTDIR/omz-custom"

#  tmux 
# Attach to the 'main' session, creating it if needed. Guarded so it only runs
# for real interactive terminals, never nested, and never inside editors.
if [[ $- == *i* ]] && [[ -z "$TMUX" ]] \
    && [[ -z "$VSCODE_INJECTION" ]] && [[ -z "$INSIDE_EMACS" ]] \
    && [[ "$TERM_PROGRAM" != "vscode" ]] \
    && command -v tmux >/dev/null 2>&1; then
    # No exec: if tmux ever fails to start, you still land in a usable shell.
    tmux new-session -A -s main
fi

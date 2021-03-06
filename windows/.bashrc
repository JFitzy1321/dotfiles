
function git_current_branch() {
    echo $(git branch --show-current)
}

# cd auto move
shopt -s autocd

# Git Aliases
alias g="git"
alias ga="git add"
alias gaa="g add -A"
alias gb="g branch"
alias gba="g branch -a"
alias gbd="g branch -d"
alias gbl="g branch -l"
alias gco="g checkout"
alias gcb="g checkout -b"
alias gcm="g commit -m"
alias gcam="g commit -a -m"
alias gd="g diff"
alias gds="g diff --staged"
alias gl="g pull"
alias gp="g push"
alias gss="g status -s"
alias gst="g status"
alias gpsu='gp --set-upstream origin "$(git_current_branch)"'
alias gpom="gp --set-upstream origin master"
alias gitclean="git branch | grep -ve ' master$' | xargs git branch -D"


# Client related aliases

# Misc Aliases
alias dotfiles="cd /c/source/dotfiles"
alias ls="ls --color=auto"
alias ll="ls -lah"
alias src="source ~/.bashrc && echo 'Re-sourcing bashrc file'"
alias tree="/c/Windows/System32/tree"




# https://wiki.archlinux.org/index.php/git#Git_prompt
source /usr/share/git/completion/git-prompt.sh
export PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
eval "$(hub alias -s)"

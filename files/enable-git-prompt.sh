# https://wiki.archlinux.org/index.php/git#Git_prompt
source /usr/share/git/completion/git-prompt.sh
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
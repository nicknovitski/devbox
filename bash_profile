# https://wiki.archlinux.org/index.php/git#Git_prompt
source /usr/share/git/completion/git-prompt.sh
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# add local gem bin for system ruby
PATH="`ruby -e 'print Gem.user_dir'`/bin:$PATH"
# same, but for bundler
export GEM_HOME=$(ruby -e 'print Gem.user_dir')

export EDITOR=vim

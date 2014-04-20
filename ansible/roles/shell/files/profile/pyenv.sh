# enable pyenv cli to path
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
# enable pyenv shims and autocompletion
eval "$(pyenv init -)"

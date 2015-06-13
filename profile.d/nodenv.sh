export NODENV_ROOT=/home/dev/.nodenv
export PATH=$NODENV_ROOT/bin:$PATH

eval "$(nodenv init -)"

# Make sure locally install binaries get priority
export PATH=node_modules/.bin:$PATH

# install global npm packages to ~
NPM_PACKAGES="$HOME/.npm-packages"

# include global npm packages in PATH
PATH="$NPM_PACKAGES/bin:$PATH"

# include global npm packages in manpath
unset MANPATH
MANPATH="$NPM_PACKAGES/share/man:$(manpath)"

{
  neovim = {
    vimAlias = true;
  };

  packageOverrides = pkgs_: with pkgs_; {
    all = with pkgs; buildEnv {
      name = "all";

      paths = [
        awscli
        ctags
        elmPackages.elm-compiler
        elmPackages.elm-make
        elmPackages.elm-package
        elmPackages.elm-reactor
        elmPackages.elm-repl
        emacs
        git
        global
        neovim
        mosh
        nox
        rcm
        readline
        tmux
        typespeed
      ];
    };
  };
}

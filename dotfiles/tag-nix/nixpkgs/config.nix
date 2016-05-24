{
  neovim = {
    vimAlias = true;
  };

  packageOverrides = pkgs_: with pkgs_; {
    all = with pkgs; buildEnv {
      name = "all";

      paths = [
        awscli
        bashCompletion
        ctags
        direnv
        elmPackages.elm-compiler
        elmPackages.elm-make
        elmPackages.elm-package
        elmPackages.elm-reactor
        elmPackages.elm-repl
        emacs
        git
        gitAndTools.hub
        global
        gtypist
        links
        neovim
        mosh
        nox
        parallel
        rcm
        rlwrap
        sdcv
        silver-searcher
        tmux
        typespeed
        weechat
        wget
      ];
    };
  };
}

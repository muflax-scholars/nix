{ pkgs }: {

packageOverrides = self: with pkgs; rec {

# standard environment; this is a bit of a hack until we run NixOS
munix = pkgs.buildEnv {
  name = "munix";
  paths = let
    hs 	= haskellPackages;
  in [
    # nix-related
    nix-prefetch-scripts
    nix-repl
    nox

    # office-y
    [libreoffice unoconv]
    (pkgs.texLiveAggregationFun {
      paths = [ texLive texLiveExtra ];
    })

    # wm
    awesome
    compton
    dmenu
    nitrogen
    parcellite
    redshift
    slock
    wmname
    xcalib

    # themes
    gnome3.gnome_icon_theme
    gtk_engines

    # vcs
    cvs
    bazaar
    darcs
    git
    gitAnnexStatic
    mercurial
    subversion

    # coding
    kde4.konsole
    silver-searcher
    xdotool
    xterm

    # text
    hs.pandoc
    kde4.okular

    # misc
    gnupg
    unison

    # games
    [wine winetricks]
    #zdoom #fails to build

    # web
    # firefox # needs custom patch
    torbrowser

    # meta
    muJ
    muJava
    muGo
    muHaskell
    muLisp
    muML
    muRust
  ];
};

cabalStatic = haskellPackages.cabal.override {
  enableStaticLibraries  	= true;
  enableSharedLibraries  	= false;
  enableSharedExecutables	= false;
};

gitAnnexStatic = haskellPackages.gitAnnex.override {
  cabal = cabalStatic;
};

muHaskell = pkgs.buildEnv {
  name = "muHaskell";
  paths = let
    hs = haskellPackages;
  in [
      # coding
      hs.cabalInstall
      hs.cabal2nix
      hs.ghc
      hs.ghcMod

      # meta
      # hs.idris # broken
  ];
};

muLisp = pkgs.buildEnv {
  name = "muLisp";
  paths = [
    # common lisp
    sbcl
    clisp
    ccl # clozurecl
    ecl

    # scheme
    chibi
    chicken
    # guile
    racket
  ];
};

muRust = pkgs.buildEnv {
  name = "muRust";
  paths = [
    rustcMaster
  ];
};

muGo = pkgs.buildEnv {
  name = "muGo";
  paths = [
    # go # build fails
  ];
};

muJ = pkgs.buildEnv {
  name = "muJ";
  paths = [
    # j # broken
  ];
};

muML = pkgs.buildEnv {
  name = "muML";
  paths = [
    ocaml
    ocamlPackages.ocaml_batteries

    # hamlet # missing
    polyml
    smlnj
  ];
};

muJava = pkgs.buildEnv {
  name = "muJava";
  paths = [
    icedtea7_jdk
  ];
};

};

# general options
allowUnfree = true;

# has some fonts bug I'm too tired to debug
unison.enableX11 = false;

}

{ pkgs }: {

packageOverrides = self: with pkgs; rec {

# standard environment; this is a bit of a hack until we run NixOS
munix = pkgs.buildEnv {
  name = "munix";
  paths = let
    hs	= haskellPackages;
    l 	= local;
  in [
    # nix-related
    gem-nix
    nix-prefetch-scripts
    nix-repl
    nox

    # office-y
    libreoffice
    unoconv
    (pkgs.texLiveAggregationFun {
      paths = [ texinfo texLive texLiveExtra texLiveCMSuper ];
    })

    # wm
    awesome
    compton
    dmenu
    nitrogen
    parcellite
    redshift
    # slock # needs suid
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
    l.gitAnnex
    mercurial
    subversion

    # coding
    cloc
    gperftools
    graphviz
    kde4.konsole
    silver-searcher
    strace
    xdotool
    xterm

    # compilers and stuff
    l.c
    l.go
    l.haskell
    l.j
    l.java
    l.javascript
    l.lisp
    l.ml
    l.rust

    # text
    calibre
    colordiff
    convmv
    dos2unix
    fbreader
    hs.pandoc
    htmlTidy
    kde4.okular
    meld
    pdftk
    wdiff
    wkhtmltopdf # giant build :<

    # languages
    hunspell
    sdcv

    # emacs
    l.emacs
    vim

    # db
    sqliteInteractive

    # misc
    gnupg
    glxinfo # <3 gears <3
    lsof
    mc
    parallel
    pwgen
    reptyr
    rlwrap
    tmux
    unison
    zsh

    # archives
    bchunk
    libarchive
    pigz
    p7zip
    rpm
    unrar

    # games
    cowsay
    wine
    winetricks
    #zdoom #fails to build

    # web
    aria2
    dropbox-cli
    l.firefox
    links
    mailutils
    mosh
    mu
    nssmdns
    offlineimap
    quvi
    rtmpdump
    s3cmd
    torbrowser
    transmission
    youtubeDL

    # audio
    audacity
    fluidsynth
    mpc
    # mpd
    ncmpc
    picard
    sox
    timidity
    vorbisgain
    vorbisTools

    # image
    geeqie
    gimp
    gimpPlugins.lqrPlugin
    imagemagick
    inkscape
    mcomix
    scrot
    xfce.ristretto

    # video
    guvcview
    l.mplayer2
    swftools

    # system
    hddtemp

  ];
};

local = recurseIntoAttrs rec {
  cabalStatic = haskellPackages.cabal.override {
    enableStaticLibraries  	= true;
    enableSharedLibraries  	= false;
    enableSharedExecutables	= false;
  };

  gitAnnex = haskellPackages.gitAnnex.override {
    cabal = cabalStatic;
  };

  haskell = pkgs.buildEnv {
    name = "haskell";
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

  lisp = pkgs.buildEnv {
    name = "lisp";
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

  rust = pkgs.buildEnv {
    name = "rust";
    paths = [
      rustcMaster
    ];
  };

  go = pkgs.buildEnv {
    name = "go";
    paths = [
      pkgs.go
    ];
  };

  j = pkgs.buildEnv {
    name = "j";
    paths = [
      # pkgs.j # broken
    ];
  };

  ml = pkgs.buildEnv {
    name = "ml";
    paths = [
      ocaml
      ocamlPackages.ocaml_batteries

      # hamlet # missing
      polyml
      smlnj
    ];
  };

  java = pkgs.buildEnv {
    name = "java";
    paths = [
      icedtea7_jdk
    ];
  };

  javascript = pkgs.buildEnv {
    name = "javascript";
    paths = [
      nodejs
    ];
  };

  c = pkgs.buildEnv {
    name = "c";
    paths = [
      gcc
      gdb
      valgrind
    ];
  };

  coq = pkgs.buildEnv {
    name = "coq";
    paths = [
      pkgs.coq
    ];
  };

  firefox-symlinks-preload = pkgs.callPackage ./firefox-symlinks-preload {};

  firefox = stdenv.lib.overrideDerivation pkgs.firefoxWrapper (old: {
    # firefox takes way too long to build, so we wrap this with LD_PRELOAD instead
    plugins = old.plugins ++ [
      (firefox-symlinks-preload + firefox-symlinks-preload.mozillaPlugin)
    ];
  });

  mplayer2 = stdenv.lib.overrideDerivation pkgs.mplayer2 (old: {
    patches = (if old ? patches then old.patches else []) ++ [
      ./mplayer2-autosub.patch
    ];
  });

  emacs = stdenv.lib.overrideDerivation pkgs.emacs (old: {
    patches = (if old ? patches then old.patches else []) ++ [
      ./emacs-key-input.patch
    ];
  });
};

};

# general options
allowUnfree = true;

# has some fonts bug I'm too tired to debug
unison.enableX11 = false;

# plugins
firefox.enableAdobeFlash      	= true;
firefox.enableGoogleTalkPlugin	= true;

}

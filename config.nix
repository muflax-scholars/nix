{ pkgs }: {

packageOverrides = self: with pkgs; rec {

# standard environment; this is a bit of a hack until we run NixOS
munix = pkgs.buildEnv {
  name = "munix";
  paths = let
    hs 	= haskellPackages;
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
      paths = [ texLive texLiveExtra ];
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
    gitAnnexStatic
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
    muC
    muGo
    muHaskell
    muJ
    muJava
    muJavaScript
    muLisp
    muML
    muRust

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

    # emacs
    emacs-patch # needs daemon
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
    firefox-patch
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
    mplayer2-patch
    swftools

    # system
    hddtemp

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
    go
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

muJavaScript = pkgs.buildEnv {
  name = "muJavaScript";
  paths = [
    nodejs
  ];
};

muC = pkgs.buildEnv {
  name = "muC";
  paths = [
    gcc
    gdb
    valgrind
  ];
};

firefox-symlinks-preload = pkgs.callPackage ./firefox-symlinks-preload {};

firefox-patch = stdenv.lib.overrideDerivation firefoxWrapper (old: {
  # firefox takes way too long to build, so we wrap this with LD_PRELOAD instead
  plugins = old.plugins ++ [
    (firefox-symlinks-preload + firefox-symlinks-preload.mozillaPlugin)
  ];
});

mplayer2-patch = stdenv.lib.overrideDerivation mplayer2 (old: {
  patches = (if old ? patches then old.patches else []) ++ [
    ./mplayer2-autosub.patch
  ];
});

emacs-patch = stdenv.lib.overrideDerivation emacs (old: {
  patches = (if old ? patches then old.patches else []) ++ [
    ./emacs-key-input.patch
  ];
});


};

# general options
allowUnfree = true;

# has some fonts bug I'm too tired to debug
unison.enableX11 = false;

# plugins
firefox.enableGoogleTalkPlugin	= true;
firefox.enableAdobeFlash      	= true;

}

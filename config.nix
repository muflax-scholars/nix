{ pkgs }: {

packageOverrides = self: with pkgs; rec {

local = let
  # shorter names
  hs = haskellPackages;

  # local overrides
  cabalStatic = haskellPackages.cabal.override {
    enableStaticLibraries  	= true;
    enableSharedLibraries  	= false;
    enableSharedExecutables	= false;
  };

  gitAnnex = stdenv.lib.overrideDerivation hs.gitAnnex (old: {
    # we pull in lsof and git anyway
    propagatedUserEnvPkgs = [];
  });

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

  # has some fonts bug I'm too tired to debug
  unison = pkgs.unison.override { enableX11 = false; };

  # japanese zips etc
  unzip = pkgs.unzip.override { enableNLS = true; };

  git = pkgs.gitAndTools.git.override { svnSupport = true; };

in recurseIntoAttrs rec {
  # standard environment; this is a bit of a hack until we run NixOS
  base = pkgs.buildEnv {
    name = "munix";
    paths = [
      # nix-related
      gem-nix
      nix-prefetch-scripts
      nix-repl
      nox

      # essential
      cowsay

      # archives
      bchunk
      gnutar
      libarchive
      pigz
      p7zip
      rpm
      unrar
      unzip

      # minor stuff
      gnupg
      mc
      parallel
      pwgen
      reptyr
      rlwrap
      tmux
      tzdata
      unison
      zsh

      # system
      extundelete
      hddtemp
      inotifyTools
      lsof
      netcat
      nmap
      utillinuxCurses
      vnstat
    ];
  };

  haskell = hiPrio (pkgs.buildEnv {
    name = "munix-haskell";
    paths = [
      hs.cabalInstall
      hs.cabal2nix
      hs.ghc
      hs.ghcMod

      # meta
      # hs.idris # broken
    ];
  });

  lisp = pkgs.buildEnv {
    name = "munix-lisp";
    paths = [
      # common lisp
      sbcl
      clisp
      ccl # clozurecl
      ecl

      # scheme
      chibi
      chicken
      guile
      racket
    ];
  };

  rust = pkgs.buildEnv {
    name = "munix-rust";
    paths = [
      rustcMaster
    ];
  };

  go = pkgs.buildEnv {
    name = "munix-go";
    paths = [
      pkgs.go
    ];
  };

  j = pkgs.buildEnv {
    name = "munix-j";
    paths = [
      # pkgs.j # broken
    ];
  };

  ml = pkgs.buildEnv {
    name = "munix-ml";
    paths = [
      ocaml
      ocamlPackages.ocaml_batteries

      # hamlet # missing
      polyml
      smlnj
    ];
  };

  java = pkgs.buildEnv {
    name = "munix-java";
    paths = [
      icedtea7_jdk
    ];
  };

  javascript = pkgs.buildEnv {
    name = "munix-javascript";
    paths = [
      nodejs
    ];
  };

  c = pkgs.buildEnv {
    name = "munix-c";
    paths = [
      gcc
      gdb
      valgrind
    ];
  };

  coq = pkgs.buildEnv {
    name = "munix-coq";
    paths = [
      pkgs.coq
    ];
  };

  office = pkgs.buildEnv {
    name = "munix-office";
    paths = [
      libreoffice
      unoconv
    ];
  };

  tex = pkgs.buildEnv {
    name = "munix-tex";
    paths = [
      (pkgs.texLiveAggregationFun {
        paths = [ texinfo texLive texLiveExtra texLiveCMSuper ];})
    ];
  };

  wm = pkgs.buildEnv {
    name = "munix-wm";
    paths = [
      awesome
      compton
      dmenu
      glxinfo # <3 gears <3
      nitrogen
      parcellite
      redshift
      # slock # needs suid
      wmname
      xcalib

      # themes
      gnome3.gnome_icon_theme
      gtk_engines
    ];
  };

  code = pkgs.buildEnv {
    name = "munix-code";
    paths = [
      # coding
      cloc
      gperftools
      graphviz
      kde4.konsole
      silver-searcher
      strace
      xdotool
      xterm

      # vcs
      cvs
      bazaar
      darcs
      git
      gitAnnex
      mercurial
      subversion

      # db
      sqliteInteractive
    ];
  };

  txt = pkgs.buildEnv {
    name = "munix-txt";
    paths = [
      # media
      calibre
      fbreader
      kde4.okular

      # edit
      colordiff
      convmv
      dos2unix
      hs.pandoc
      htmlTidy
      meld
      pdftk
      wdiff

      # languages
      aspell
      aspellDicts.en	# for some tools that rely on aspell
      hunspell      	# normal dict with dicts in ~/
      sdcv

      # emacs
      emacs
      vim
    ];
  };

  web = pkgs.buildEnv {
    name = "munix-web";
    paths = [
      aria2
      # chromium # giant build :<
      dropbox-cli
      firefox
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
      # wkhtmltopdf # giant build :<

      # evernote needs packaging, manual deps for now
      opencv
      qt48Full
    ];
  };

  audio = pkgs.buildEnv {
    name = "munix-audio";
    paths = [
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
    ];
  };

  video = pkgs.buildEnv {
    name = "munix-video";
    paths = [
      guvcview
      mplayer2
      swftools
    ];
  };

  image = pkgs.buildEnv {
    name = "munix-image";
    paths = [
      geeqie
      gimp
      gimpPlugins.lqrPlugin
      imagemagick
      inkscape
      mcomix
      scrot
      xfce.ristretto
    ];
  };

  games = pkgs.buildEnv {
    name = "munix-games";
    paths = [
      wine
      winetricks
    ];
  };

};

};

# general options
allowUnfree = true;

# browser plugins
firefox.enableAdobeFlash      	= true;
firefox.enableGoogleTalkPlugin	= true;

}

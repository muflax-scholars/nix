{ pkgs }: {

packageOverrides = self: with pkgs; rec {

local = let
  # shorter names
  hs  	= haskellPackages;
  odev	= stdenv.lib.overrideDerivation;
  py2 	= python2Packages;
  py3 	= python3Packages;

  # local overrides
  cabalStatic = haskellPackages.cabal.override {
    enableStaticLibraries  	= true;
    enableSharedLibraries  	= false;
    enableSharedExecutables	= false;
  };

  firefox-symlinks-preload = pkgs.callPackage ./firefox-symlinks-preload {};

  firefox = odev pkgs.firefoxWrapper (old: {
    # firefox takes way too long to build, so we wrap this with LD_PRELOAD instead
    plugins = old.plugins ++ [
      (firefox-symlinks-preload + firefox-symlinks-preload.mozillaPlugin)
    ];
  });

  mplayer2 = odev pkgs.mplayer2 (old: {
    patches = (if old ? patches then old.patches else []) ++ [
      ./mplayer2-autosub.patch
    ];
  });

  emacs = odev pkgs.emacs (old: {
    name = "emacs-24.3";
    src = fetchurl {
      url    = "mirror://gnu/emacs/emacs-24.3.tar.xz";
      sha256 = "1385qzs3bsa52s5rcncbrkxlydkw0ajzrvfxgv8rws5fx512kakh";
    };
    # On NixOS, help Emacs find `crt*.o'.
    configureFlags = old.configureFlags ++ stdenv.lib.optional (stdenv ? glibc)
      [ "--with-crt-dir=${stdenv.glibc}/lib" ];

    patches = (if old ? patches then old.patches else []) ++ [
      ./emacs-key-input.patch
    ];

    # debugging
    dontStrip = true;
  });

  anki = odev pkgs.anki (old: {
    patches = (if old ? patches then old.patches else []) ++ [
      ./anki-profile.patch
      ./anki-search-results.patch
    ];

    # rebuild patched UI
    buildInputs = old.buildInputs ++ [perl pyqt4];
    buildPhase = ''
      ./tools/build_ui.sh
    '';
  });

  # has some fonts bug I'm too tired to debug
  unison = pkgs.unison.override { enableX11 = false; };

  zathura = odev pkgs.zathuraCollection.zathuraWrapper (_: {
    zathura_core = odev pkgs.zathuraCollection.zathuraWrapper.zathura_core (old : {
      patches = (if old ? patches then old.patches else []) ++ [
        ./zathura-path.patch
      ];
    });
  });

  # workaround because we don't run Nix' avahi-daemon yet
  mosh = odev pkgs.mosh (old: {
    buildInputs = old.buildInputs ++ [ nssmdns ];
    postInstall = ''
      wrapProgram $out/bin/mosh \
        --prefix PERL5LIB : $PERL5LIB \
        --prefix LD_LIBRARY_PATH : ${nssmdns}/lib
    '';
  });

  bup = pkgs.bup.override { par2Support = true; };

in recurseIntoAttrs rec {
  # standard environment; this is a bit of a hack until we run NixOS
  base = hiPrio(pkgs.buildEnv {
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
      bup
      bchunk
      gnutar
      libarchive
      par2cmdline
      pigz
      p7zip
      rpm
      unrar
      unzipNLS

      # minor stuff
      figlet
      gnupg
      htop
      iotop
      mc
      parallel
      pinentry
      powertop
      pwgen
      reptyr
      rlwrap
      time
      sl
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
  });

  haskell = hiPrio (pkgs.buildEnv {
    name = "munix-haskell";
    paths = [
      hs.cabalInstall
      hs.cabal2nix
      hs.ghc
      hs.ghcMod
    ];
  });

  idris = pkgs.buildEnv {
    name = "munix-idris";
    paths = [
      hs.idris
    ];
  };

  agda = pkgs.buildEnv {
    name = "munix-agda";
    paths = [
      # needs conflicts resolved
      hs.Agda
      agdaPrelude
      AgdaStdlib
      AgdaSheaves
    ];
  };

  lisp = pkgs.buildEnv {
    name = "munix-lisp";
    paths = [
      # common lisp
      ccl # clozurecl
      clisp
      ecl
      gcl
      sbcl

      # scheme
      chibi
      chicken
      gambit
      guile
      mitscheme
      racket
      # stalin # missing

      # clojure
      clojure
      leiningen
    ];
  };

  rust = pkgs.buildEnv {
    name = "munix-rust";
    paths = [
      cargoSnapshot
      rustcMaster
    ];
  };

  j = pkgs.buildEnv {
    name = "munix-j";
    paths = [
      pkgs.j
    ];
  };

  ml = pkgs.buildEnv {
    name = "munix-ml";
    paths = [
      ocaml
      ocamlPackages.ocaml_batteries

      # hamlet # missing
      aliceml
      manticore
      polyml
      smlnj
    ];
  };

  java = lowPrio (pkgs.buildEnv {
    name = "munix-java";
    paths = [
      icedtea7_jdk
    ];
  });

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
      libnotify
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
      sloccount
      silver-searcher
      strace
      xdotool
      xterm

      # vcs
      bazaar
      cvs
      darcs
      gitAndTools.darcsToGit
      # gitAndTools.git-remote-bzr # missing
      gitAndTools.git-remote-hg
      gitFull
      hs.gitAnnex
      mercurial
      subversion

      # db
      sqliteInteractive
      sqliteman

      # libs
      readline
    ];
  };

  txt = pkgs.buildEnv {
    name = "munix-txt";
    paths = [
      # media
      calibre
      fbreader
      pdfgrep
      zathura

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

      # anki
      anki
    ];
  };

  web = pkgs.buildEnv {
    name = "munix-web";
    paths = [
      awscli
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
      torbrowser
      transmission # needs qt version
      youtubeDL
      w3m
      # wkhtmltopdf # giant build :<
      wicd
    ];
  };

  audio = pkgs.buildEnv {
    name = "munix-audio";
    paths = [
      audacity
      fluidsynth
      mpc_cli
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

  d = pkgs.buildEnv {
    name = "munix-d";
    paths = [
      dmd
    ];
  };

  # keep pythons in separate buildenvs so their priorities work
  python2env = pkgs.python2Full.buildEnv.override {
    extraLibs = [
      py2.iso8601
      py2.mock
      py2.pip
      py2.pyyaml
      py2.simplejson
      py2.sqlalchemy
      py2.unidecode
      py2.xlib
      py2.beautifulsoup
      py2.requests

    ];
  };

  python3env = pkgs.python3.buildEnv.override {
    extraLibs = [

    ];
  };

  python2 = hiPrio (pkgs.buildEnv {
    name = "munix-python2";
    paths = [
      python2env
    ];
  });

  python3 = pkgs.buildEnv {
    name = "munix-python3";
    paths = [
      python3env
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

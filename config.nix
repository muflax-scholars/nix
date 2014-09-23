{ pkgs }: {

packageOverrides = self: with pkgs; rec {

# standard environment; this is a bit of a hack until we run NixOS
munix = pkgs.buildEnv {
  name = "munix";
  paths = [
    # nix-related
    nix-prefetch-scripts
    nix-repl
    nox

    # big, annoying packages
    libreoffice
    torbrowser
    wine
    winetricks

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

      # tools
      darcs
      gitAnnexStatic
      hs.pandoc

      # meta
      # hs.idris
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
    # hamlet #missing
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

}

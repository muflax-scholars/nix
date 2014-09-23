{

packageOverrides = pkgs: with pkgs; rec {

# standard environment; this is a bit of a hack until we run NixOS
munix = pkgs.buildEnv {
  name = "munix";
  paths = [
    # nix-related
    nox

    # meta
    muHaskell
    muLisp
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
  paths = [
    (haskellPackages.ghcWithPackages (self : [
      #haskellPlatform
      self.pandoc
      gitAnnexStatic
      # self.ghcMod

    ]))
  ];

};
  ];
};

};

# general options
allowUnfree = true;

}

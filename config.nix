{

packageOverrides = pkgs: with pkgs; rec {

# standard environment; this is a bit of a hack until we run NixOS
munix = pkgs.buildEnv {
  name = "munix";
  paths = [
  	# nix-related
  	nox
  ];
};

};

# general options
allowUnfree = true;

}

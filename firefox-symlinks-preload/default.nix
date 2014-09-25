{ stdenv }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "firefox-symlinks-preload";

  src = ./preload.c;
  unpackPhase = "true";

  installPhase = ''
      plugins=$out/lib/mozilla/plugins
      mkdir -p $plugins

      libdir=$out/libexec/firefox
      mkdir -p $libdir

      # Generate an LD_PRELOAD wrapper to redirect execvp() calls to
      preload=$out/libexec/firefox/with-links-as-files.so
      mkdir -p $(dirname $preload)
      gcc -shared ${./preload.c} -o $preload -ldl -DOUT=\"$out\" -fPIC
      echo $preload > $plugins/extra-ld-preload
  '';


  dontStrip = true;
  dontPatchELF = true;

  passthru.mozillaPlugin = "/lib/mozilla/plugins";
}

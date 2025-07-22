{
  lib,
  fetchgit,
  git,
  buildRubyGem,
  writeShellScriptBin,
  pkg-config,
  ruby,
  rake,
  defaultGemConfig,
  bundlerEnv,
  gobject-introspection,
  cairo,
  pango,
  gdk-pixbuf,
  librsvg,
  harfbuzz,
  glib,
  imagemagick, # for mini_magick
  makeFontsConf,
  ...
}: fontDirectories: let
  squib-git = buildRubyGem {
    pname = "squib-git";
    gemName = "squib";
    version = "0.19.0-dev";
    src = fetchgit {
      url = "https://github.com/andymeneely/squib.git";
      rev = "d052e1f2cd2a36791dd540441db4e5c64bd3b365";
      sha256 = "sha256-GHf6G2nKcO7yDvPGka6hJfSI77n+9p2VpzbonkamJwc=";
    };
    nativeBuildInputs = [ git ]; # Needed for the gemspec
  };

  gemConfig =
    defaultGemConfig
    // {
      rsvg2 = attrs: {
        nativeBuildInputs = [pkg-config rake];
        buildInputs = [librsvg];
      };
    };
  
  vendorGems = bundlerEnv {
    name = "squib-vendor-gems";
    inherit ruby;
    inherit gemConfig;
    gemdir = ./.;
  };

  fontsConf = makeFontsConf { inherit fontDirectories; };
  
  runtimeInputs = [
    squib-git
    vendorGems
    ruby
    gobject-introspection
    cairo
    pango
    gdk-pixbuf
    librsvg
    harfbuzz
    glib
    imagemagick
  ];
in
  writeShellScriptBin "ruby"
  #sh
  ''
    ulimit -n 65536 2>/dev/null
    export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
    export LD_LIBRARY_PATH="${lib.makeLibraryPath runtimeInputs}:$LD_LIBRARY_PATH"
    export GI_TYPELIB_PATH="${lib.makeSearchPathOutput "lib" "lib/girepository-1.0" runtimeInputs}:$GI_TYPELIB_PATH"
    
    # GEM_PATH that puts git-built squib first
    export GEM_PATH="${squib-git}/lib/ruby/gems/3.3.0:${vendorGems}/lib/ruby/gems/3.3.0"

    export G_MESSAGES_DEBUG=all
    export XDG_CACHE_HOME="$(mktemp -d)"
    export FONTCONFIG_FILE="$XDG_CACHE_HOME/fonts.conf"
    cp "${fontsConf}" "$FONTCONFIG_FILE"
    exec ${ruby}/bin/ruby "$@"
  ''

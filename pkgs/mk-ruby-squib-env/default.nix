{
  lib,
  stdenv,
  fetchFromGitHub,
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
  imagemagick,
  makeFontsConf,
  ...
}: fontDirectories: let
  squib-fork = stdenv.mkDerivation {
    pname = "squib-fork";
    version = "0.20.0a";
    
    src = fetchFromGitHub {
      owner = "silvarc141";
      repo = "squib";
      rev = "e5324bf741d8f9f63f15dd62af7d0ed144b7e33c";
      sha256 = "sha256-ioIpzYZ82596JwOUntvpYZIKtvOTC/ERX/vasQNc1TA=";
    };
    
    nativeBuildInputs = [ ruby ];

    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';
  };

  rubyEnv = bundlerEnv {
    name = "squib-env-final";
    inherit ruby;
    gemdir = ./.;
    gemConfig = defaultGemConfig // {
      rsvg2 = attrs: {
        nativeBuildInputs = [pkg-config rake];
        buildInputs = [librsvg];
      };
      squib = attrs: {
        src = squib-fork;
      };
    };
  };

  fontsConf = makeFontsConf { inherit fontDirectories; };
  
  runtimeInputs = [
    rubyEnv
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
    ulimit -n 65536 2/dev/null
    export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
    export LD_LIBRARY_PATH="${lib.makeLibraryPath runtimeInputs}:$LD_LIBRARY_PATH"
    export GI_TYPELIB_PATH="${lib.makeSearchPathOutput "lib" "lib/girepository-1.0" runtimeInputs}:$GI_TYPELIB_PATH"
    export GEM_PATH="${rubyEnv}/lib/ruby/gems/3.3.0"
    export G_MESSAGES_DEBUG=all
    export XDG_CACHE_HOME="$(mktemp -d)"
    export FONTCONFIG_FILE="$XDG_CACHE_HOME/fonts.conf"
    cp "${fontsConf}" "$FONTCONFIG_FILE"
    exec ${ruby}/bin/ruby "$@"
  ''

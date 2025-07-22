{
  lib,
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
  gemConfig =
    defaultGemConfig
    // {
      rsvg2 = attrs: {
        nativeBuildInputs = [pkg-config rake];
        buildInputs = [librsvg];
      };
    };
  gems = bundlerEnv {
    name = "squib";
    inherit ruby;
    inherit gemConfig;
    gemdir = ./.;
  };
  fontsConf = makeFontsConf { inherit fontDirectories; };
  runtimeInputs = [
    gems
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
    # Increase file descriptor limit to handle many icons.
    ulimit -n 65536 2>/dev/null

    export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
    export LD_LIBRARY_PATH="${lib.makeLibraryPath runtimeInputs}:$LD_LIBRARY_PATH"
    export GI_TYPELIB_PATH="${lib.makeSearchPathOutput "lib" "lib/girepository-1.0" runtimeInputs}:$GI_TYPELIB_PATH"
    export GEM_PATH="${gems}/lib/ruby/gems/3.3.0"
    
    export G_MESSAGES_DEBUG=all

    export XDG_CACHE_HOME="$(mktemp -d)"
    export FONTCONFIG_FILE="$XDG_CACHE_HOME/fonts.conf"
    cp "${fontsConf}" "$FONTCONFIG_FILE"

    exec ${ruby}/bin/ruby "$@"
  ''

{
  lib,
  pkg-config,
  writeShellScriptBin,

  rake,
  defaultGemConfig,
  bundlerEnv,

  squib-src,
  gobject-introspection,
  cairo,
  pango,
  gdk-pixbuf,
  librsvg,
  harfbuzz,
  glib,
  makeFontsConf,

  # List of directories which the env will scan for fonts.
  fontDirectories ? [ ],

  # This only adds packages to PATH.
  # Adding an actual gem would require modyfing the Gemfile and relocking with bundix.
  extraPackages ? [ ],
  ...
}:
let
  inherit (lib)
    makeBinPath
    makeSearchPathOutput
    makeLibraryPath
    ;

  fontsConf = makeFontsConf { inherit fontDirectories; };

  rubyEnv = bundlerEnv {
    name = "ruby-bundler-env-squib";
    gemdir = ./.;
    gemConfig = defaultGemConfig // {
      rsvg2 = attrs: {
        nativeBuildInputs = [
          pkg-config
          rake
        ];
        buildInputs = [ librsvg ];
      };
      squib = attrs: {
        src = squib-src;
      };
    };
  };

  runtimeInputs = [
    rubyEnv
    gobject-introspection
    cairo
    pango
    gdk-pixbuf
    librsvg
    harfbuzz
    glib
  ]
  ++ extraPackages;
in
writeShellScriptBin "ruby-squib-env" ''
  ulimit -n 65536 2/dev/null
  export PATH="${makeBinPath runtimeInputs}:$PATH"
  export LD_LIBRARY_PATH="${makeLibraryPath runtimeInputs}:$LD_LIBRARY_PATH"
  export GI_TYPELIB_PATH="${
    makeSearchPathOutput "lib" "lib/girepository-1.0" runtimeInputs
  }:$GI_TYPELIB_PATH"
  export XDG_CACHE_HOME="$(mktemp -d)"
  export FONTCONFIG_FILE="$XDG_CACHE_HOME/fonts.conf"
  cp "${fontsConf}" "$FONTCONFIG_FILE"

  export BUNDLE_GEMFILE="${rubyEnv.confFiles}/Gemfile"
  export RUBYOPT="-rbundler/setup"
  exec ${rubyEnv.wrappedRuby}/bin/ruby "$@"
''

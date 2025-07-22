{
  lib,
  ruby,
  bundlerEnv,
  makeFontsConf,
  defaultGemConfig,
  stdenv,
  fetchurl,
  buildEnv,

  pkg-config,
  rake,
  bundler,
  gnumake,
  git,
  gnutar,
  gzip,

  cairo,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  pango,
  librsvg,
  libxml2,
  libxslt,

  imagemagick,
  ...
}: fontDirectories: let
  allNativeBuildInputs = [
    pkg-config
    rake
    bundler
    gnumake
    git
  ] ++ lib.unique (
    [ cairo gdk-pixbuf glib gobject-introspection pango librsvg libxml2 libxslt ]
    ++ cairo.propagatedBuildInputs
    ++ gdk-pixbuf.propagatedBuildInputs
    ++ glib.propagatedBuildInputs
    ++ gobject-introspection.propagatedBuildInputs
    ++ pango.propagatedBuildInputs
    ++ librsvg.propagatedBuildInputs
  );

  rsvg2-patched = stdenv.mkDerivation {
    pname = "rsvg2-patched-source";
    version = "4.2.9";
    src = fetchurl {
      url = "https://rubygems.org/gems/rsvg2-4.2.9.gem";
      sha256 = "1sq0j1jy16m63a9hnsf01dszyrzd1asg0qpyb8fws14abh7vc8dx";
    };
    nativeBuildInputs = [ gnutar gzip ];
    unpackPhase = ''
      tar xf $src
      tar xzf data.tar.gz
    '';
    patchPhase = ''
      substituteInPlace rsvg2.gemspec \
        --replace '"dependency-check/Rakefile"' '"ext/rsvg2/extconf.rb"'
    '';
    installPhase = ''
      mkdir -p $out
      cp -R . $out
    '';
  };

  gems = bundlerEnv {
    name = "squib-env-base"; # Renamed
    inherit ruby;
    gemdir = ./.;
    nativeBuildInputs = allNativeBuildInputs;
    gemConfig = defaultGemConfig // {
      rsvg2 = _: { source = { type = "path"; path = rsvg2-patched; }; };
    };
    meta.dependencies = [
      imagemagick
      (makeFontsConf { inherit fontDirectories; })
    ];
  };
in
  buildEnv {
    name = "squib-environment";
    paths = [ gems ];
  }

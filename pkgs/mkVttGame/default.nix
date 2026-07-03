{
  lib,
  zip,
  libwebp,
  runCommandNu,
  ...
}:
{
  gameName,
  images,
}:
runCommandNu (baseNameOf ./.) { } ''
  $env.PATH = $env.PATH | append "${zip}/bin" | append "${libwebp}/bin"
  source ${./lib.nu}
  packageImagesAsVttGame ${images} $out ${gameName}
''

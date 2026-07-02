{
  lib,
  zip,
  runCommandNu,
  ...
}:
{
  gameName,
  images,
}:
runCommandNu (baseNameOf ./.) { } ''
  $env.PATH = $env.PATH | append "${zip}/bin"
  source ${./lib.nu}
  packageImagesAsVttGame ${images} $out ${gameName}
''

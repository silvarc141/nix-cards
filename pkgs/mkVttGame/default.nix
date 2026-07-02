{
  lib,
  runCommand,
  nushell,
  zip,
  runCommandNu,
}:
{
  name,
  images,
}:
runCommandNu (baseNameOf ./.) { } ''
  $env.PATH = $env.PATH | append "${zip}/bin"
  source ${./lib.nu}
  packageImagesAsVttGame ${images} $out ${name}
''

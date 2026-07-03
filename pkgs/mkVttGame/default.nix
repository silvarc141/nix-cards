{
  lib,
  zip,
  libwebp,
  busybox,
  runCommandNu,
  ...
}:
{
  gameName,
  images,
}:
runCommandNu (baseNameOf ./.) { } ''
  $env.PATH = $env.PATH | append "${zip}/bin" | append "${libwebp}/bin" | append "${busybox}/bin"
  source ${./lib.nu}
  packageImagesAsVttGame ${images} $out ${gameName}
''

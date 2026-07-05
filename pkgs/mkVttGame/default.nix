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
  use ${./lib.nu} *
  packageCardImagesAsVttGame ${images} $out ${gameName}
''

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
runCommandNu (baseNameOf ./.)
  {
    nativeBuildInputs = [
      zip
      libwebp
      busybox
    ];
  }
  ''
    use ${./lib.nu} *
    packageCardImagesAsVttGame ${images} $env.out ${gameName}
  ''

{
  pkgsSelf,
  utils,
  ...
}:
utils.callPackagesInDirectory ./. pkgsSelf

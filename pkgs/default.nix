{
  pkgsSelf,
  utils,
  ...
}:
utils.callPackagesInDirectory ./. (pkgsSelf // utils)

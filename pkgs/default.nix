{
  pkgsSelf,
  utils,
  squib-src,
  ...
}:
utils.callPackagesInDirectory ./. (pkgsSelf // utils // { inherit squib-src; })

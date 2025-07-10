{pkgsSelf, utils, ...}: utils.callPackagesInDirectory ./. {inherit pkgsSelf;}

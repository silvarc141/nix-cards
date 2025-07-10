{pkgs, pkgsSelf, utils, ...}: utils.callPackagesInDirectory ./. {inherit pkgs pkgsSelf;}

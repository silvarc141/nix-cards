#!/usr/bin/env bash

rm -f gemset.nix
rm -f Gemfile.lock

nix flake update squib-src
BUNDLE_FORCE_RUBY_PLATFORM=true nix shell nixpkgs#bundler nixpkgs#bundix --command sh -c "bundle lock; bundix"

rm -rf .bundlecache

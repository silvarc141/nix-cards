#!/usr/bin/env bash

rm gemset.nix
rm Gemfile.lock
BUNDLE_FORCE_RUBY_PLATFORM=true nix run nixpkgs#bundix -- --lock

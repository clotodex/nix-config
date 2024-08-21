#!/usr/bin/env bash

source .env
export NIX_CONFIG

nix-channel --update || exit
nh os switch --update || exit
git add flake.lock
git commit -m "chore: update system"

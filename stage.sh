#!/usr/bin/env zsh

if [ $(whoami) != root ]; then
	echo "This must run as root!"
	exit
fi
cp ./configuration.nix /etc/nixos/configuration.nix
nixos-rebuild switch

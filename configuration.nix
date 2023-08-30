{ pkgs, config, ... }:

{
	# Import hardware configuration
	imports = [
		./hardware-configuration.nix
	];
	# Configure boot
	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
		timeout = 0;
	};

	# Configure basic options
	networking  = {
		hostName = "nixos";
		nameservers = [ "1.1.1.1" "9.9.9.9" "8.8.8.8" ];
		firewall = {
			allowedTCPPorts = [ 22 ];
		};
	};
	time.timeZone = "Europe/Rome";

	i18n.defaultLocale = "en_US.UTF-8";
	console = {
		font = "Lat2-Terminus16";
		keyMap = "it";
	};

	# Install system wide programs
	environment.systemPackages = with pkgs; [
		wget
		micro
		git
		gh
		distrobox
		man
		lsd
	];

	# enable and configure zsh
	programs.zsh = {
		enable = true;
		autosuggestions.enable = true;
		ohMyZsh = {
			enable = true;
			theme = "crunch";
		};
		shellAliases = {
			ls = "lsd";
			ll = "lsd -l";
			la = "lsa -lA";
			rm = "rm -r";
		};
	};
	environment.shells = [
		pkgs.zsh
		pkgs.bash
	];

	# Enable and configure podman for distrobox
	virtualisation.podman = {
		enable = true;
		autoPrune.enable = true;
		dockerCompat = true;
	};

	# Configure btrfs trim
	services.btrfs.autoScrub = {
		enable = true;
		interval = "weekly";
	};

	# Print ip address on tty login to ssh
	environment.etc."issue.d/ip.issue".text = "\\4\n";
	networking.dhcpcd.runHook = "${pkgs.utillinux}/bin/agetty --reload";

	# Enable openssh daemon
	services.openssh = {
		enable = true;
		settings = {
			PasswordAuthentication = false;
			KbdInteractiveAuthentication = false;
			PermitRootLogin = "no";
		};
	};

	# Enable doas (a sudo alternative)
	security.doas = {
		enable = true;
		wheelNeedsPassword = true;
	};
	# User Configuration
	users.users = {
		admin = {
			isNormalUser = true;
			extraGroups = [ "wheel" ];
			group = "users";
			home = "/home/admin";
			openssh.authorizedKeys.keyFiles = [
				"/etc/nixos/ssh/authorized_keys/nixos.pub"
			];
		};
	};

	users.defaultUserShell = pkgs.zsh;

	# Final System Configuration
	system.copySystemConfiguration = true;
	system.stateVersion = "23.05";
}

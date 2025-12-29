{ config, lib, pkgs, ... }: {

  environment.persistence."/safe"  = {
		enable = true;
		hideMounts = true;
    
		directories = [
		  "/etc/nixos"
		  "/var/lib/flatpak"
		  "/var/lib/nixos"
		  "/var/lib/nixos-containers"
		  "/var/lib/systemd/coredump"
		  "/var/lib/bluetooth"
		  "/etc/NetworkManager/system-connections" 
		];
		files = [
		  "/etc/machine-id"
		];
	};	
}
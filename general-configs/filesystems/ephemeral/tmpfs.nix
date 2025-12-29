{ config, lib, pkgs, fsRoot ... }: 

let 
	fs = fsRoot;
in

{
	fileSystems = { 
  	"/safe" = { 
      device = "/dev/disk/by-label/nixos";
      fsType = fs;
      options = [ "fmask=0077" "dmask=0077" ];
    };
	};

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
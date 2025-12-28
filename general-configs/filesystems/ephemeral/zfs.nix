{ config, lib, pkgs, ... }: {
  # configura comando pós post para raiz efêmera com zfs
  boot = {
    initrd.systemd = {
      enable = true;
      services.initrd-rollback-root = {
        after = [ 
          "zfs-import-nixos.service"
        ];
        wantedBy = [ 
          "initrd.target" 
        ];
        before = [ 
          "sysroot.mount" 
        ];
        path = with pkgs; [ zfs ];
        description = "Rollback para SnapShot em branco";
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r nixos/system/root@blank
        '';
      };
    };
  };

	# persistencia de um sistema efêmero
	environment.persistence."/safe" = {
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
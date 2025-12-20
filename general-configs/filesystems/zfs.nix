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
  # particionamento
  fileSystems = {
    "/" = {
      device = "nixos/system/root";
      fsType = "zfs";
    };
    "/nix" = {
      device = "nixos/system/nix";
      fsType = "zfs";
    };
    "/persist" = {
      device = "nixos/system/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
  };
}
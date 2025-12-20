{ config, lib, pkgs, modulesPath, ... }: {
  
# -------- FILESYSTEM --------

  # nunca tocar
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # persistencia de um sistema efêmero
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/lib/flatpak"
      "/var/lib/nixos"
      "/var/lib/nixos-containers"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections" 
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  # TempHome
  specialisation = {
    Home = {
      inheritParentConfig = true; # herda a configuração pai
      configuration = {
        system.nixos.tags = [ "Home" ]; # define as tags no boot
        # Logs na ram
        services.journald.extraConfig = ''
          Storage = volatile
          RuntimeMaxUse = 128M
        '';
        # home separada
        fileSystems = {
          "/home" = {
            device = "/dev/disk/by-label/home";
            fsType = "xfs";
            options = [ "mode=0755" "noatime" "nofail" "nodiratime" "x-systemd.device-timeout=5" ];
          };
          # cache na ram
          "/home/vulkce/.cache" = {
            device = "none";
            fsType = "tmpfs";
            options = [ "defaults" "mode=0755" "size=512M" ];
          };
          "/home/vulkce/Downloads/" = {
            device = "none";
            fsType = "tmpfs";
            options = [ "defaults" "mode=0755" "size=1GB" ];
          };
        };
      };
    };
    TempHome = {
      inheritParentConfig = true;
      configuration = {
        system.nixos.tags = [ "TempHome" ];
        # home interna
        fileSystems."/home" = {
          device = "none"; 
          fsType = "tmpfs"; # filesystem temporário na ram
          options = [ "size=8G" "mode=777" ]; # options para o tmpfs
        };
        # usa systemd para criar uma home
        systemd.tmpfiles.settings."10-home-vulkce" = {
          "/home/vulkce".d = {
            mode = "0755";
            user = "vulkce";
            group = "users";
          };
        };
      };
    };
  };
}
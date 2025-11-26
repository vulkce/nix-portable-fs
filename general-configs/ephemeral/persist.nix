{ config, pkgs, ... }: {

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/lib/nixos"
      "/var/lib/nixos-containers"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/general-configs"
      "/home-manager"
      "/.git" 
    ];
    files = [
      "/etc/machine-id"
      "/flake.nix"
      "/flake.lock"
    ];
  };
}

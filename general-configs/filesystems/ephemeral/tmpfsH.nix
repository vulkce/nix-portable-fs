{ config, lib, pkgs, ... }: {

  systemd.tmpfiles.settings."10-home-vulkce" = {
    "/home/vulkce".d = {
      mode  = "0755";
      user  = "vulkce";
      group = "users";
    };
  };

  environment.persistence."/safe" = {
    enable = true;
    hideMounts = true;

    users.vulkce = {
      directories = [
        ".cache/nix"
        ".ssh"
        "Desktop"
        "Pictures"
        "Projects"
        "Videos"
        ".config"
        ".local/share"
        ".var"
        ".nix-defexpr"
        ".pki"
      ];
      files = [ 
        ".gitconfig" 
        ".env"
        ".gtkrc-2.0"
      ];
    };
  };
}
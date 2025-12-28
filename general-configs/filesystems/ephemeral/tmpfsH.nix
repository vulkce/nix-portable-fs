{ config, lib, pkgs, ... }: {

  environment.persistence."/nix/safe/home" = {
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
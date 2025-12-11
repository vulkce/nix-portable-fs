{ config, lib, pkgs, ... }: {

  users.users.vulkce = {
    isNormalUser = true;
    createHome = false;
    home = "/home/vulkce"; 
    hashedPasswordFile = "/persist/passwords/vulkce";
    extraGroups = [ "wheel" "networkmanager" "vboxusers" "docker"];
    
    # pacotes do usuário
    packages = with pkgs; [
      tree
      vscodium
      prismlauncher
      vesktop
      gnome-secrets
      mission-center
    ];
  };

}

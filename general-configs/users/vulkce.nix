{ config, lib, pkgs, ... }: {

  users.users.vulkce = {
    isNormalUser = true;
    home = "/home/vulkce"; 
    hashedPasswordFile = "/persist/passwords/vulkce";
    extraGroups = [ "wheel" "networkmanager" "vboxusers" "docker"];
    
    # Se o /home não estiver montado, cria um temporário
    createHome = true;
    
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

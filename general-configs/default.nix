{ config, lib, pkgs, modulesPath, ... }: {

  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix") # importa configurações de hardware não detectadas 
    ./filesystems/zfs.nix # importa o filesystem
    
    ./system.nix # importa as configurações do sistema
    ./interfaces.nix #importa as interfaces
    ./packages/packages.nix # importa os pacotes
    ./packages/special-pkgs.nix # importa pacotes especiais
  ];
};
{ config, lib, inputs, pkgs, ... }: {  

 imports = [
   
   # a lista é separada considerando sua pasta!

   # configura como um sistema efêmero
   ./ephemeral/ephemeral.nix
   ./ephemeral/persist.nix
   ./ephemeral/subvolume.nix
   
   # configuração do sistema
   ./system/basic.nix
   ./system/optimization.nix
   ./system/mounts.nix

   # usuários
   ./users/vulkce.nix
   
   # pacotes e programas
   ./packages/packages.nix
   ./packages/flatpak.nix
   ./packages/especial-pkgs.nix

   # configurações de DEs/WMs
   ./interfaces/DEs.nix
   ./interfaces/WMs.nix

   # remover bloatware de DEs
   ./exclude/gnome.nix
 ];

} 

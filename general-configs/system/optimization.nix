{ config, lib, inputs, pkgs, ... }: {

  boot.kernelParams = [
    "idle=poll" # pode reduzir latencia
    "amd_pstate=active" # o hardware controla
    # "isolcpus=<cpus>" # isola cores.
  ];

  # otimiza o /nix/store trocando arquivos duplicados por hardlinks
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ]; # otimiza diariamente
  };

  # chama o caminhão de lixo pro nix
  nix.gc = {
    automatic = false;
    dates = [ "weekly" ]; # chama semanalmente
   # options = "--delete-older-than 30d"; # deleta todas a generations
  };

  # habilita zram
  zramSwap = {
    enable = true;
    memoryPercent = 75;
    algorithm = "lzo-rle"; # I love lzo-rle
    priority = 5; # preferencia pela zram
  };

  # swap normal
#  swapDevices = [
#    {
#      device = "/dev/disk/by-uuid/d2b636cc-bf0e-4fb8-8448-ee032ebfdc8d"; # sempre usem UUIDs!!!
#      priority = 0; # usa o swap quando a zram encher
#    }
#  ];

} 

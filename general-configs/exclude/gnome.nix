{ config, lib, pkgs, ... }: {

  # remover o bloatware do gnome
  environment.gnome.excludePackages = (with pkgs; [
    atomix
    cheese
    epiphany
    geary
    gnome-music
    gnome-photos
    gnome-tour
    hitori
    iagno
    tali
    totem
 ]);

}

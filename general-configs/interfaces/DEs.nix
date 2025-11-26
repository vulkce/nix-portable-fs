{ config, lib, inputs, pkgs, ... }: {

  # xserver
  services.xserver.enable = true

  # SDDM
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.cosmic-greeter.enable = false;

  # PLASMA
  services.desktopManager.plasma6.enable = true;

  # COSMIC
  services.desktopManager.cosmic.enable = false;

  # GNOME
  services.desktopManager.gnome.enable = false;

  # XFCE
  services.xserver.desktopManager.xfce.enable = true;

  # cinnamon
  services.xserver.desktopManager.cinnamon.enable = false;

  # evitar conflito entre gnome e kde
 # programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

}

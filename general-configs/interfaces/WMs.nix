{ config, lib, inputs, pkgs, ... }: {

  # hyprland
  programs.hyprland = {  
    enable = true;
    xwayland.enable = true;
  }; 

  # i3 WM
  services.xserver.windowManager.i3.enable = false;

  # sway
  programs.sway.enable = false;

  # openbox
  services.xserver.windowManager.openbox.enable = false;

}

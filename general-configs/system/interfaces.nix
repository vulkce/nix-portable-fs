{ config, lib, inputs, pkgs, ... }: {

  # xserver
  services.xserver.enable = true;

# -------- LOGIN --------

  services.displayManager = {
    cosmic-greeter.enable = true; # cosmic greeter
    sddm = { # SDDM
      enable = false;
      wayland.enable = false;
    };
  };

# -------- DEs --------

  services = { 
    # WAYLAND
    desktopManager = { 
      plasma6.enable = false; # plasma
      cosmic.enable = true; # cosmic
      gnome.enable = false; # gnome
    };
    # xserver
    xserver.desktopManager = { 
      xfce.enable = true; # xfce
      cinnamon.enable = false; # cinnamon
    };
  };

# -------- WMs -------- 

  # wayland WMs
  programs = {
    sway.enable = false; # sway
    hyprland = { # hyprland
      enable = true;
      xwayland.enable = true;
    };      
  }; 
  
  # xserver WMs
  services.xserver.windowManager = {
    i3.enable = false; # i3 WM
    openbox.enable = false; # openbox
  };

# -------- EXCLUDE --------

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

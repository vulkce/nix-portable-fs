{ config, lib, inputs, pkgs, ... }: {
  
  services = {
    # LOGIN_MANAGER
    displayManager = {
      cosmic-greeter.enable = false; # cosmic greeter
      sddm = { # SDDM
        enable = true;
        wayland.enable = true;
      };
    };
    # WAYLAND
    desktopManager = { # DEs
      plasma6.enable = true; # plasma
      cosmic.enable = false; # cosmic
      gnome.enable = false; # gnome
    };
    # xserver
    xserver = {
      enable = false; # habilita o servidor X
      windowManager = { # WMs
        i3.enable = false; # i3 WM
        openbox.enable = false; # openbox
      };
      desktopManager = { # DEs
        xfce.enable = false; # xfce
        cinnamon.enable = false; # cinnamon
      };
    };
  };

  # wayland WMs
  programs = {
    sway.enable = false; # sway
    hyprland = { # hyprland
      enable = true;
      xwayland.enable = true;
    };      
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

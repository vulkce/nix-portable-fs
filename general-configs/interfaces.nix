{ config, lib, inputs, pkgs, ... }: {
  
  services = {
    # LOGIN_MANAGER
    displayManager = {
      cosmic-greeter.enable = true; # cosmic greeter
      sddm = { # SDDM
        enable = false;
        wayland.enable = false;
      };
    };
    # WAYLAND
    desktopManager = { # DEs
      plasma6.enable = false; # plasma
      cosmic.enable = false; # cosmic
      gnome.enable = true; # gnome
    };
    # xserver
    xserver = {
      enable = false; # habilita o servidor X
      # configura o teclado
      xkb.layout = "us";
      xkb.variant = "intl";
      
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

  # define o input, ibus é pesado
  # fcitx5 é ótimo para velocidade!
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      qt6Packages.fcitx5-configtool
    ];
  };

  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE  = "fcitx";
    XMODIFIERS    = "@im=fcitx";
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

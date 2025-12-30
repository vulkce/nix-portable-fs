{ config, pkgs, inputs, ... }: {

  home = {
    username = "vulkce";
    homeDirectory = "/home/vulkce";
    stateVersion = "26.05";
    packages = with pkgs; [
      flatpak
      firefox
      tree
      vesktop
      mission-center
      prismlauncher
      vscodium
      gnome-secrets
      jetbrains.idea
      protonvpn-gui
      obs-studio
    ];
  };

  services.flatpak = {
    enable = true; # habilita a flatpak
    # repositórios flatpak
    remotes = [
      { 
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo"; 
      }
      {
        name = "gnome-nightly"; 
        location = "https://nightly.gnome.org/gnome-nightly.flatpakrepo"; 
      } 
      {
        name = "elementaryos"; 
        location = "https://flatpak.elementary.io/repo.flatpakrepo"; 
      }  
      { 
        name = "PureOS"; 
        location = "https://store.puri.sm/repo/stable/pureos.flatpakrepo"; 
      }
    ];
    # aplicativos declarados
    packages = [
      { 
        appId = "app.zen_browser.zen"; 
        origin = "flathub"; 
      }
      {
        appId = "net.newpipe.NewPipe";
        origin = "flathub";
      }
      {
        appId = "org.raspberrypi.rpi-imager";
        origin = "flathub";
      }
      {
        appId = "com.bitwarden.desktop";
        origin = "flathub";
      }
    ];
    # update automatico
    update = {
      onActivation = true;
      auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "vulkce";
      user.email = "vulkce@proton.me";
    };
  };
}

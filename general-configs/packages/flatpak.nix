{ config, pkgs, ... }: {

  services.flatpak.enable = true; # habilita a flatpak

  # repositórios usados para instalar aplicativos
  services.flatpak.remotes = [
    
    { name = "flathub"; location = "https://flathub.org/repo/flathub.flatpakrepo"; }
    { name = "gnome-nightly"; location = "https://nightly.gnome.org/gnome-nightly.flatpakrepo"; } 
    { name = "elementaryos"; location = "https://flatpak.elementary.io/repo.flatpakrepo"; }  
    { name = "PureOS"; location = "https://store.puri.sm/repo/stable/pureos.flatpakrepo"; }
  
  ];
  
  # aplicativos declarados
  services.flatpak.packages = [
    { appId = "app.zen_browser.zen"; origin = "flathub"; }
              "org.vinegarhq.Sober"
  ];

  # atualização automática:
  services.flatpak.update.onActivation = true;
  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly";
  };

}

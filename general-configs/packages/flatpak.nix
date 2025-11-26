{ config, pkgs, ... }: {

  services.flatpak.enable = true; # habilita a flatpak

  # repositório usado para instalar aplicativos
  services.flatpak.remotes = [
    { name = "flathub"; location = "https://flathub.org/repo/flathub.flatpakrepo"; }
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

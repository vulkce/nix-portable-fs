{ config, lib, pkgs, inputs, ... }: {

    environment.systemPackages = with pkgs; [

    # coisas úteis
    usbutils
    wget
    kdePackages.qtstyleplugin-kvantum
    gparted
    fastfetch
    obs-studio
    gnome-disk-utility
    
    # non-free
    unrar
    
    # desenvolvimento
    pipenv
    python314
    rustc
    nodejs
    devspace

    # coisas para WMs & DEs
    alacritty
    wl-clipboard
    swaybg
    hyprpaper
    waybar
    labwc

#    inputs.zen-browser.packages.${system}.default # zen-browser

   ];

}

{ config, pkgs, ... } {

    home.username = "vulkce";
    home.homeDirectory = "/home/vulkce/";
    home.stateVersion = "25.11";

    home.packages = with pkgs; [];

    programs.git = {
      enable = true;
      userName = "vulkce";
      userEmail = "vulkce@proton.me";

    };

}

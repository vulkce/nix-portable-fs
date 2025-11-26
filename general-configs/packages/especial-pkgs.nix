{ config, lib, inputs, pkgs, ... }: {

# -------- STEAM --------

    programs.steam = {
      enable = true;

      # opções necessárias para jogos onlines
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    # instala pacotes essenciais para a steam
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"

  ];

# de acordo com a wiki, ativar o gamescope manualmente não é preciso em GPUs amd!!! :)

# -------- DOCKER --------

# irei adicionar mais coisas em breve :)

    virtualisation.docker = {
      enable = false;
      daemon.settings = {
        experimental = true;
        default-address-pools = [
        {
          base = "172.30.0.0/16"; # define os ips dos containers
          size = 24; # pode ser dividido em 24 ips
        }
      ];
    };
  };



# -------- VIRTUALBOX --------

 # VirtualBox (compilar isso é muito chato!!!)
#   virtualisation.virtualbox.host = {
#     enable = true;
#     enableKvm = hasKvm;  # usa KVM
#     addNetworkInterface = true; # ativa as opções de rede dentro do virtualbox
#  };


# -------- OPENSSH --------

    services.openssh = {
      enable = true;
      ports = [ 4080 ]; # porta do servidor ssh
      settings = {
        PasswordAuthentication = true; # permite login por senha
        KbdInteractiveAuthentication = false; # login interativo
        PermitRootLogin = "no"; # login no root
        AllowUsers = [ "vulkce" ];
      };
    };

}

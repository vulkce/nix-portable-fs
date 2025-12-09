{ config, lib, inputs, pkgs, ... }:

#let

#  kubeMasterIP = "10.1.1.2";
#  kubeMasterHostname = "api.kube";
#  kubeMasterAPIServerPort = 6443;

#in

{

# -------- STEAM --------

#    programs.steam = {
#      enable = true;

      # opções necessárias para jogos onlines
#      remotePlay.openFirewall = true;
#      dedicatedServer.openFirewall = true;
#      localNetworkGameTransfers.openFirewall = true;
#    };

    # instala pacotes essenciais para a steam
#    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
#      "steam"
#      "steam-original"
#      "steam-unwrapped"
#      "steam-run"
#    ];

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

# -------- KUBERNETES --------

  # resolve master hostname
#  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # packages for administration tasks
#  environment.systemPackages = with pkgs; [
#    kompose
#    kubectl
#    kubernetes
#  ];

#  services.kubernetes = {
#    roles = ["master" "node"];
#    masterAddress = kubeMasterHostname;
#    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
#    easyCerts = true;
#    apiserver = {
#      securePort = kubeMasterAPIServerPort;
#      advertiseAddress = kubeMasterIP;
#    };

    # use coredns
#    addons.dns.enable = true;

    # needed if you use swap
#    kubelet.extraOpts = "--fail-swap-on=false";
#  };

# -------- NH --------

  # habilita o nh
  programs.nh = {
    enable = true;
    clean.enable = true; # faz o trabalho do cg
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/persist/"; # localização da minha flake
  };

}

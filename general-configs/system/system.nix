{ config, lib, pkgs, modulesPath, ... }: {

# -------- NIXOS --------

  # define e configura options do boot
  boot = {
    kernelPackages = pkgs.linuxPackages_lqx; # kernel LQX, kernel com foco em baixa latencia e gaming
    kernelModules = [ "kvm-amd" "hid_playstation" "hid_sony" "uinput" ]; # modulos do kernel
    supportedFilesystems = [ "zfs" ]; # filesystems extras
    loader.systemd-boot.enable = true; # usa systemd-boot
    zfs.removeLinuxDRM = true; # protege o zfs caso futuras atts de kernels quebrem o zfs por conta da GPL
  };

  # nome do sistema
  networking = {
    hostName = "flake"; # configura o hostname 
    hostId = "8bec9fba"; # configura o hostId para o zfs
    networkmanager.enable = true; # usa o networkmanager
  };

  # pipewire
  services.pipewire = {
    enable = true;
    pulse.enable = true; # ativa compatibilidade com pulseaudio
    jack.enable = true; # ativa compatibilidade com o jack
  };

  # habilita o bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # inicia o bluetooth no boot
    settings.General = {
      ControllerMode = "bredr";
      Experimental = true; # mostra mais informações sobre o dispositivo
    };
  };

  # firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 4580 9090 ];
    allowedUDPPorts = [ ];
  };

  nix = {
    optimise = { # otimiza o /nix/store trocando arquivos duplicados por hardlinks
      automatic = true;
      dates = [ "daily" ]; # otimiza diariamente
    };
    gc = { # chama o caminhão de lixo pro nix
      automatic = false;
      dates = [ "weekly" ]; # chama semanalmente
    };
    settings = { # configura o uso de várias threads
      max-jobs = "auto"; # usa todos os cores
      cores = 0; # distribui a carga
    };
  };

  # timezone
  time.timeZone = "America/Sao_Paulo";

  # experimental
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # unfree
  nixpkgs.config.allowUnfree = true;

  # versão no qual a primeira build foi feita!
  system.stateVersion = "25.11";

# -------- HARDWARE --------

  # define o perfil de energia como performace
  powerManagement = {
    cpuFreqGovernor = "performance";
  };

  boot.kernelParams = [
    "idle=poll" # pode reduzir latencia
    "amd_pstate=active" # o hardware controla
    # "isolcpus=<cpus>" # isola cores.
  ];

  # habilita zram
  zramSwap = {
    enable = true;
    memoryPercent = 75;
    algorithm = "lz4";
    priority = 5; # preferencia pela zram
  };

  # configura a GPU corretamente
  hardware = {
    amdgpu.opencl.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # swap normal
#  swapDevices = [
#    {
#      device = "/dev/disk/by-uuid/d2b636cc-bf0e-4fb8-8448-ee032ebfdc8d"; # sempre usem UUIDs!!!
#      priority = 0; # usa o swap quando a zram encher
#    }
#  ];

  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.extraModulePackages = [ ];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

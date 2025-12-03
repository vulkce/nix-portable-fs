{ config, lib, pkgs, modulesPath, ... }: {

# -------- NIXOS --------

  # usa systemd-boot
  boot.loader.systemd-boot.enable = true;

  # define e configura o kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-amd" "hid_playstation" "hid_sony" "uinput" ]; # modulos do kernel

  # nome do sistema
  networking.hostName = "flake";

  # usa o networkmanager
  networking.networkmanager.enable = true;

  # timezone
  time.timeZone = "America/Sao_Paulo";

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
  };

  # configura o bluetooth
  hardware.bluetooth.settings = {
    General = {
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

  # experimental
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # unfree
  nixpkgs.config.allowUnfree = true;

  # versão no qual a primeira build foi feita!
  system.stateVersion = "25.11";

# -------- OPTIMIZATION --------

  boot.kernelParams = [
    "idle=poll" # pode reduzir latencia
    "amd_pstate=active" # o hardware controla
    # "isolcpus=<cpus>" # isola cores.
  ];

  # otimiza o /nix/store trocando arquivos duplicados por hardlinks
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ]; # otimiza diariamente
  };

  # chama o caminhão de lixo pro nix
  nix.gc = {
    automatic = false;
    dates = [ "weekly" ]; # chama semanalmente
   # options = "--delete-older-than 30d"; # deleta todas a generations
  };

  # habilita zram
  zramSwap = {
    enable = true;
    memoryPercent = 75;
    algorithm = "lzo-rle"; # I love lzo-rle
    priority = 5; # preferencia pela zram
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # swap normal
#  swapDevices = [
#    {
#      device = "/dev/disk/by-uuid/d2b636cc-bf0e-4fb8-8448-ee032ebfdc8d"; # sempre usem UUIDs!!!
#      priority = 0; # usa o swap quando a zram encher
#    }
#  ];



# -------- HARDWARE --------

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

  # habilita suporte ao openZFS
#  networking.hostId = "8bec9fba";
#  boot.supportedFilesystems = [ "zfs" ];


}

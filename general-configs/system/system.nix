{ config, lib, pkgs, modulesPath, ... }: {

# -------- NIXOS --------

  # define e configura options do boot
  boot = {
    # kernel e boot
    kernelPackages = pkgs.linuxPackages_lqx; # kernel LQX, kernel com foco em baixa latencia e gaming
    kernelModules = [ # modulos do kernel
      "kvm-amd" 
      "hid_playstation" 
      "hid_sony" 
      "uinput" 
    ];
    kernelParams = [
      "idle=poll" # pode reduzir latencia
      "amd_pstate=active" # o hardware controla
      # "isolcpus=<cpus>" # isola cores.
    ];
    initrd.availableKernelModules = [ 
      "xhci_pci" 
      "ahci" 
      "usbhid" 
      "usb_storage" 
      "sd_mod" 
    ];
    initrd.kernelModules = [ 
      "dm-snapshot" 
    ];
    # configura comando pós post para raiz efêmera com zfs
    initrd.systemd = {
      enable = true;
      services.initrd-rollback-root = {
        after = [ "zfs-import-rpool.service" ];
        wantedBy = [ "initrd.target" ];
        before = [ "sysroot.mount" ];
        path = [ pkgs.zfs ];
        description = "Rollback para SnapShot em branco";
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r rpool/local/root@blank
        '';
      };
    };
    loader.systemd-boot.enable = true; # usa systemd-boot
    # zfs
    supportedFilesystems = [ "zfs" ]; # filesystems extras
    zfs.removeLinuxDRM = true; # protege o zfs caso futuras atts de kernels quebrem o zfs por conta da GPL
  };

  # options do networking
  networking = {
    hostName = "flake"; # configura o hostname 
    hostId = "8bec9fba"; # configura o hostId para o zfs
    networkmanager.enable = true; # usa o networkmanager
    useDHCP = lib.mkDefault true; # usa o DHCP
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 4580 9090 ];
      allowedUDPPorts = [ ];
    };
  };

  # pipewire
  services.pipewire = {
    enable = true;
    pulse.enable = true; # ativa compatibilidade com pulseaudio
    jack.enable = true; # ativa compatibilidade com o jack
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
      experimental-features = [ "nix-command" "flakes" ]; # experimental
    };
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux"; # faz o nixpkgs seguir a arch da CPU
    config.allowUnfree = true; # permite pacotes unfree
  };

  # timezone
  time.timeZone = "America/Sao_Paulo";

  # versão no qual a primeira build foi feita!
  system.stateVersion = "25.11";

# -------- Users --------

  users.users.vulkce = {
    isNormalUser = true;
    createHome = false;
    home = "/home/vulkce"; 
    hashedPasswordFile = "/persist/passwords/vulkce";
    extraGroups = [ "wheel" "networkmanager" "vboxusers" "docker" ];
    
    # pacotes do usuário
    packages = with pkgs; [
      tree
      vscodium
      prismlauncher
      vesktop
      gnome-secrets
      mission-center
    ];
  };

# -------- HARDWARE --------

  # define o perfil de energia como performace
  powerManagement = {
    cpuFreqGovernor = "performance";
  };

  # habilita zram
  zramSwap = {
    enable = true;
    memoryPercent = 75;
    algorithm = "lz4";
    priority = 5; # preferencia pela zram
  };

  hardware = {
    # cpu microcode
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    # configura GPU corretamente
    amdgpu.opencl.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    # bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true; # inicia o bluetooth no boot
      settings.General = {
        ControllerMode = "bredr";
        Experimental = true; # mostra mais informações sobre o dispositivo
      };
    };
  };

  # importa configurações de hardware não detectadas 
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
}

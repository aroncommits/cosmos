# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    inputs.hardware.nixosModules.system76
    ./hardware-configuration.nix
    ../common.nix
    ./experimental.nix
  ];

  # Kernel
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # System76
  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    system76.enableAll = true;

    graphics.enable = true;

    nvidia = {
      # https://nixos.wiki/wiki/Nvidia
      modesetting.enable = true;
      prime = {
        sync.enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };

      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;

      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    graphics.enable32Bit = true;
    graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-f049a6fd-4311-49db-a162-e5ed47deda90".device = "/dev/disk/by-uuid/f049a6fd-4311-49db-a162-e5ed47deda90";
  boot.initrd.luks.devices."luks-f049a6fd-4311-49db-a162-e5ed47deda90".keyFile = "/crypto_keyfile.bin";

  # Enable SDA on luks
  environment.etc."crypttab".text = ''
    sda-luks /dev/disk/by-uuid/b071583d-7257-4322-80ca-8e18c991b724 /root/sda.keyfile
  '';

  # TODO fix me
  fileSystems."/home/aron/projects" = {
    device = "/dev/disk/by-uuid/9ec39ce1-0fef-41c8-a7a3-88c4674684c4";
    fsType = "ext4";
  };

  # Define the hostname
  networking.hostName = "system76";

  services.xserver.videoDrivers = [ "nvidia" ];

  # Fix screen tearing
  services.xserver.screenSection = ''
    Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ ];
}

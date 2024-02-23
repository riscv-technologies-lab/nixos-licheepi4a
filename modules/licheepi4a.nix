{
  lib,
  pkgs,
  ...
}: {
  # =========================================================================
  #      Board specific configuration
  # =========================================================================

  boot = {
    kernelPackages = pkgs.linuxPackages_thead;

    initrd.includeDefaultModules = false;
    initrd.availableKernelModules = lib.mkForce [
      "ext4"
      "sd_mod"
      "mmc_block"
      "spi_nor"
      "xhci_hcd"
      "usbhid"
      "hid_generic"
    ];
  };

  systemd.services."serial-getty@hvc0" = {
    enable = false;
  };

  # Some filesystems (e.g. zfs) have some trouble with cross (or with BSP kernels?) here.
  boot.supportedFilesystems = lib.mkForce [
    "vfat"
    "ext4"
    "btrfs"
  ];

  powerManagement.cpuFreqGovernor = "ondemand";
  hardware = {
    deviceTree = {
      # https://github.com/revyos/thead-kernel/blob/lpi4a/arch/riscv/boot/dts/thead/light-lpi4a.dts
      # https://github.com/chainsx/fedora-riscv-builder/blob/51841d872b/config/config-emmc.txt
      name = "thead/light-lpi4a.dtb";
      overlays = [
        # custom deviceTree here
      ];
    };
    enableRedistributableFirmware = true;

    # TODO GPU driver
    opengl = {
      enable = false;
    };

    # firmwares
    firmware = [
      # TODO add GPU firmware
    ];
  };

  # =========================================================================
  #      Base NixOS Configuration
  # =========================================================================

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    neofetch
    lm_sensors
    htop
    mtdutils
    i2c-tools
    minicom
  ];

  services.openssh = {
    enable = true;
  };

  system.stateVersion = "24.05";
}

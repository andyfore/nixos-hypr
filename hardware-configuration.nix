{ lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot = {
    initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sr_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-uuid/0a88e535-8af3-4f04-8842-06a6421d671b";
        fsType = "ext4";
      };
    "/boot" =
      {
        device = "/dev/disk/by-uuid/B1F5-A287";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };
    "/mnt/nas" =
      {
        device = "192.168.40.11:/volume1/DiskStation54TB";
        fsType = "nfs";
        options = [ "rw" "bg" "soft" "tcp" "_netdev" ];
      };
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

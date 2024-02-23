{
  mkShell,
  pkgs,
  ...
}:
mkShell {
  nativeBuildInputs = with pkgs; [
    nix-output-monitor
    cloud-utils
    e2fsprogs
    usbutils
    arp-scan
  ];
}

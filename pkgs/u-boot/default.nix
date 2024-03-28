{
  buildUBoot,
  fetchFromGitHub,
  thead-opensbi,
}:
(buildUBoot {
  version = "2023.08.06";

  src = fetchFromGitHub {
    owner = "revyos";
    repo = "thead-u-boot";
    rev = "e0247b8a622a08256bb876fe706eedd3d5d645f7";
    hash = "sha256-N5BTOUSdygOdBVH+rsgkrccf9BPKjKBZA/WWN1BOPQ8=";
  };

  defconfig = "light_lpi4a_defconfig";

  extraMeta.platforms = [ "riscv64-linux" ];
  extraMakeFlags = [ "OPENSBI=${thead-opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin" ];

  filesToInstall = [ "u-boot-with-spl.bin" ];
}).overrideAttrs
  (oldAttrs: {
    patches = [ ]; # Remove all patches, which is not compatible with thead-u-boot
  })

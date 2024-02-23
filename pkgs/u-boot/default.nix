{
  buildUBoot,
  fetchFromGitHub,
  thead-opensbi,
}:
(buildUBoot {
  version = "2023.08.06";

  src = fetchFromGitHub {
    owner = "riscv-technologies-lab";
    repo = "thead-u-boot";
    rev = "990e122d26d1ef94f4e0e1bbf5d7df58e8393eee";
    sha256 = "sha256-JB2hVrTDpUc0iI+IhNzLcWs8XhJCY8vK4KgEiDsmxiA=";
  };

  defconfig = "light_lpi4a_defconfig";

  extraMeta.platforms = ["riscv64-linux"];
  extraMakeFlags = [
    "OPENSBI=${thead-opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin"
  ];

  filesToInstall = ["u-boot-with-spl.bin"];
})
.overrideAttrs (oldAttrs: {
  patches = []; # Remove all patches, which is not compatible with thead-u-boot
})

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
    rev = "43a2b1f1a1a06527f585ac504ecc78f42e0e6830";
    sha256 = "sha256-kLr+MLOeQPpAVwvtjNUCHYVj2qBD8NwtBQXifgQEQKY=";
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

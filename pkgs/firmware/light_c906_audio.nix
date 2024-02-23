{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "light_c906_audio-firmware";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "riscv-technologies-lab";
    repo = "th1520-boot-firmware";
    rev = "c1b04c6b38cbf9e71a9b6091ab5cf9974d586cd6";
    sha256 = "sha256-noPwJlV0krqHnyM2c5K3HTr0efhvOIVicWvZpywN3Hk=";
  };

  buildCommand = ''
    install -Dm444 $src/addons/boot/light_c906_audio.bin $out/lib/firmware/light_c906_audio.bin
  '';
}

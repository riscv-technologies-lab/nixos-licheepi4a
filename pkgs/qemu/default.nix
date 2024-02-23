# This file is basically a stripped down version of the old nixpkgs derivation
# for qemu 6.1.0:
# https://github.com/NixOS/nixpkgs/blob/988da51d9c49a1d43fe28a5f92394f5dbc16eede/pkgs/applications/virtualization/qemu/default.nix
# I've stripped it down as much as possible, since some of the workarounds don't
# seem necessary for the newer versions of nixpkgs and other dependencies.
# Additionally this derivation builds qemu targeting only riscv64. This way the compile
# times are kept reasonable and the derivation becomes less complicated.
{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  zlib,
  pkg-config,
  glib,
  perl,
  pixman,
  vde2,
  texinfo,
  flex,
  bison,
  lzo,
  snappy,
  libtasn1,
  gnutls,
  nettle,
  curl,
  ninja,
  meson,
  autoPatchelfHook,
  python311Packages,
  ...
}:
stdenv.mkDerivation {
  pname = "thead-qemu";
  version = "6.0.94";

  src = fetchFromGitHub {
    owner = "riscv-technologies-lab";
    repo = "thead-qemu";
    rev = "ab8f84892a89feea60f1bb24432ff58ce6d2885c";
    sha256 = "sha256-Lo+X/s75O6yTKCS3YQEBe8CpUizMHTE1HNRRcI722mg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs =
    [python3 python311Packages.sphinx-rtd-theme python311Packages.sphinx pkg-config flex bison meson ninja]
    ++ lib.optionals stdenv.isLinux [autoPatchelfHook];

  buildInputs = [
    zlib
    glib
    perl
    pixman
    vde2
    texinfo
    lzo
    snappy
    libtasn1
    gnutls
    nettle
    curl
  ];

  dontUseMesonConfigure = true;

  outputs = ["out"];

  postPatch = ''
    # Otherwise tries to ensure /var/run exists.
    sed -i "/install_subdir('run', install_dir: get_option('localstatedir'))/d" \
        qga/meson.build
  '';

  preConfigure = ''
    chmod +x ./scripts/shaderinclude.pl
    unset CPP
    patchShebangs .
    mv VERSION QEMU_VERSION
    substituteInPlace configure \
      --replace '$source_path/VERSION' '$source_path/QEMU_VERSION'
    substituteInPlace meson.build \
      --replace "'VERSION'" "'QEMU_VERSION'"
  '';

  configureFlags = let
    targets = [
      "riscv64-softmmu"
      "riscv64-linux-user"
    ];
  in [
    "--target-list=${builtins.concatStringsSep "," targets}"
  ];

  doCheck = false;

  postFixup = ''
    rm -f $out/share/applications/qemu.desktop
  '';

  preBuild = "cd build";

  meta = with lib; {
    homepage = "https://github.com/revyos/qemu";
    description = "A generic and open source machine emulator and virtualizer";
    license = licenses.gpl2Plus;
    maintainers = [];
    platforms = platforms.unix;
  };
}

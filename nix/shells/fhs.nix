{
  pkgsCross,
  pkgs,
  arch,
  abi,
}:
# The code here is mainly copied from:
# - https://nixos.wiki/wiki/Linux_kernel#Embedded_Linux_Cross-compile_xconfig_and_menuconfig
(pkgs.buildFHSEnv {
  name = "kernel-build-env";
  targetPkgs = pkgs_: (with pkgs_;
    [
      pkg-config
      ncurses
      pkgsCross.stdenv.cc
      gcc
    ]
    ++ pkgs.linux.nativeBuildInputs);
  runScript = pkgs.writeScript "init.sh" ''
    # Set the cross-compilation environment variables.
    export CROSS_COMPILE=riscv64-unknown-linux-gnu-
    export ARCH=riscv
    export PKG_CONFIG_PATH="${pkgs.ncurses.dev}/lib/pkgconfig:"

    # Set the CFLAGS and CPPFLAGS as described here:
    # - https://github.com/graysky2/kernel_compiler_patch#alternative-way-to-define-a--march-option-without-this-patch
    export KCFLAGS=' -march=${arch} -mabi=${abi}'
    export KCPPFLAGS=' -march=${arch} -mabi=${abi}'

    exec bash
  '';
})
.env

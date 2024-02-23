{
  description = "NixOS running on LicheePi 4A";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # According to https://github.com/sipeed/LicheePi4A/blob/pre-view/.gitmodules
    thead-kernel = {
      url = "github:revyos/thead-kernel/lpi4a";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    # Custom T-HEAD extensions implemented in gcc-13 by the following patches:
    # - https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;h=8351535f20b52cf332791f60d2bf22a025833516
    # - https://gcc.gnu.org/gcc-13/changes.html
    # Other extensions might be buggy, xtheadcondmov and xtheadmempair lead to
    # internal compiler errors.
    # TODO: Reproduce the issue and file upstream bug.
    # Possibly related bugs:
    # - https://gcc.gnu.org/bugzilla/show_bug.cgi?id=109760
    # - https://gcc.gnu.org/bugzilla/show_bug.cgi?id=110095
    thead_extensions = [
      "ba"
      "bb"
      "bs"
      "fmemidx"
      "fmv"
      "mac"
      "memidx"
    ];

    # https://nixos.wiki/wiki/Build_flags
    # This option equals to add `-march=${arch}` into CFLAGS.
    # CFLAGS will be used as the command line arguments for the gcc/clang.
    # NOTE: CFLAGS is not used by the kernel build system! so this would not work for the kernel build.
    arch =
      "rv64gc_"
      + (builtins.concatStringsSep "_"
        (builtins.map (e: "xthead${e}") thead_extensions));

    # The same as `-mabi=${abi}` in CFLAGS.
    # Related docs:
    # - https://github.com/riscv-non-isa/riscv-toolchain-conventions/blob/master/README.mkd#specifying-the-target-abi-with--mabi
    # - https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/cc-wrapper/default.nix
    abi = "lp64d";

    inherit (self.outputs) overlays;

    crossSystem = {
      config = "riscv64-unknown-linux-gnu";
      gcc = {inherit arch abi;};
    };

    pkgsCross = import nixpkgs {
      localSystem = "x86_64-linux";
      crossSystem = crossSystem;
      overlays = [overlays.lp4a];
    };

    pkgsHost = import nixpkgs {
      system = "x86_64-linux";
      overlays = [overlays.host];
    };
  in {
    overlays = {
      default = overlays.lp4a;
      lp4a = import ./nix/cross-overlay.nix {
        inherit inputs;
        inherit (pkgsHost) thead-qemu;
      };
      host = import ./nix/host-overlay.nix;
    };

    nixosConfigurations.lp4a-cross = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        {
          nixpkgs = {
            crossSystem = crossSystem;
            overlays = [overlays.lp4a];
          };
        }

        ./modules/licheepi4a.nix
        ./modules/sd-image/sd-image-lp4a.nix
        ./modules/user-group.nix
      ];
    };

    packages.x86_64-linux = {
      thead-qemu = pkgsHost.thead-qemu;
      uboot = pkgsCross.callPackage ./pkgs/u-boot {};
      sdImage = self.nixosConfigurations.lp4a-cross.config.system.build.sdImage;
    };

    # Use `nix develop .#fhsEnv` to enter the fhs test environment defined here.
    devShells.x86_64-linux.fhsEnv =
      # The code here is mainly copied from:
      # - https://nixos.wiki/wiki/Linux_kernel#Embedded_Linux_Cross-compile_xconfig_and_menuconfig
      (pkgsHost.buildFHSUserEnv {
        name = "kernel-build-env";
        targetPkgs = pkgs_: (with pkgs_;
          [
            # we need theses packages to run `make menuconfig` successfully.
            pkg-config
            ncurses

            pkgsCross.stdenv.cc
            gcc
          ]
          ++ pkgsHost.linux.nativeBuildInputs);
        runScript = pkgsHost.writeScript "init.sh" ''
          # set the cross-compilation environment variables.
          export CROSS_COMPILE=riscv64-unknown-linux-gnu-
          export ARCH=riscv
          export PKG_CONFIG_PATH="${pkgsHost.ncurses.dev}/lib/pkgconfig:"

          # Set the CFLAGS and CPPFLAGS as described here:
          # - https://github.com/graysky2/kernel_compiler_patch#alternative-way-to-define-a--march-option-without-this-patch
          export KCFLAGS=' -march=${arch} -mabi=${abi}'
          export KCPPFLAGS=' -march=${arch} -mabi=${abi}'

          exec bash
        '';
      })
      .env;
  };
}

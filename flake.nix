{
  description = "NixOS running on LicheePi 4A";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
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

    pkgsCrossFor = system:
      (import nixpkgs) {
        localSystem.system = system;
        crossSystem = crossSystem;
        overlays = [overlays.build];
        crossOverlays = [overlays.lp4a];
      };

    systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "riscv64-linux"];
  in
    {
      overlays = {
        default = overlays.lp4a;
        lp4a = import ./nix/overlays/cross.nix;
        build = import ./nix/overlays/build.nix;
      };

      nixosConfigurations.lp4a-cross = (pkgsCrossFor "x86_64-linux").nixos {
        imports = [
          ./modules/licheepi4a.nix
          ./modules/sd-image/sd-image-lp4a.nix
          ./modules/user-group.nix
        ];
      };

      nixConfig = {
        extra-substituters = [
          "https://attic.aeronas.ru/lp4a"
        ];
        extra-trusted-public-keys = [
          "lp4a:Om07le0y+rXgyAo7tM2gWoWVKok18uqrxI7GB9DLtIE="
        ];
      };
    }
    // flake-utils.lib.eachSystem systems
    (system: let
      pkgsCross = pkgsCrossFor system;
      buildPkgs = pkgsCross.buildPackages;
      pkgs = import nixpkgs {inherit system;};
    in {
      packages = {
        thead-qemu = buildPkgs.thead-qemu;
        uboot = pkgsCross.thead-uboot;
        sdImage = self.nixosConfigurations.lp4a-cross.config.system.build.sdImage;
      };

      # Use `nix develop .#fhsEnv` to enter the fhs test environment defined here.
      devShells =
        {
          default = pkgs.callPackage ./nix/shells/dev.nix {};
        }
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          fhsEnv = import ./nix/shells/fhs.nix {inherit pkgsCross pkgs abi arch;};
        };
    });
}

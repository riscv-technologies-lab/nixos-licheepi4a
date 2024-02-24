# This overlay is applied to the whole package set. It's needed to override the
# default emulator, which is required to build cross-packages.
# NOTE: Name arguments as prev and final, so that nix flake check does not error out.
final: prev: {
  # This is necessary to make mesonEmulatorHook point to the correct emulator,
  # since we are building the system with vendor-specific extensions, so regular
  # qemu will trap on custom instructions.
  qemu = final.thead-qemu;
  thead-qemu = prev.callPackage ../../pkgs/qemu {};
}

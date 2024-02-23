# This overlay is applied to the whole package set. It's needed to override the
# default emulator, which is required to build cross-packages.
self: super: {
  # This is necessary to make mesonEmulatorHook point to the correct emulator,
  # since we are building the system with vendor-specific extensions, so regular
  # qemu will trap on custom instructions.
  qemu = self.thead-qemu;
  thead-qemu = super.callPackage ../../pkgs/qemu {};
}

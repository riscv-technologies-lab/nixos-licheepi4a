{thead-qemu}: self: super: let
  # Make this particular warning non-fatal, since when cross-compiling this
  # warning results in extra warnings for error-handling code. This is either a false
  # positive from gcc13 or a bug in systemd. Neither is particularly critical, since
  # this code is not in the hot path.
  overrideFormatWError = final: prev: {
    env.NIX_CFLAGS_COMPILE = prev.env.NIX_CFLAGS_COMPILE + " -Wno-error=format-overflow";
  };
in {
  linuxPackages_thead = super.linuxPackagesFor (super.callPackage ../pkgs/kernel {
    kernelPatches = with super.kernelPatches; [
      bridge_stp_helper
      request_key_helper
    ];
  });

  light_aon_fpga = super.callPackage ../pkgs/firmware/light_aon_fpga.nix {};
  light_c906_audio = super.callPackage ../pkgs/firmware/light_c906_audio.nix {};
  thead-opensbi = super.callPackage ../pkgs/opensbi {};

  # This is necessary to make mesonEmulatorHook point to the correct emulator,
  # since we are building the system with vendor-specific extensions, so regular
  # qemu will trap on custom instructions.
  qemu = thead-qemu;

  systemdLibs = super.systemdLibs.overrideAttrs overrideFormatWError;
  systemdMinimal = super.systemdMinimal.overrideAttrs overrideFormatWError;
  systemd = super.systemd.overrideAttrs overrideFormatWError;
}

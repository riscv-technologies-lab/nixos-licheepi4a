# This overlay should be applied via crossOverlays, since does not need to change the
# build packages in any way.
final: prev: let
  # Make this particular warning non-fatal, since when cross-compiling this
  # warning results in extra warnings for error-handling code. This is either a false
  # positive from gcc13 or a bug in systemd. Neither is particularly critical, since
  # this code is not in the hot path.
  overrideFormatWError = final: prev: {
    env.NIX_CFLAGS_COMPILE = prev.env.NIX_CFLAGS_COMPILE + " -Wno-error=format-overflow";
  };
in {
  linuxPackages_thead = prev.linuxPackagesFor (prev.callPackage ../../pkgs/kernel {
    kernelPatches = with prev.kernelPatches; [
      bridge_stp_helper
      request_key_helper
    ];
  });

  light_aon_fpga = prev.callPackage ../../pkgs/firmware/light_aon_fpga.nix {};
  light_c906_audio = prev.callPackage ../../pkgs/firmware/light_c906_audio.nix {};
  thead-opensbi = prev.callPackage ../../pkgs/opensbi {};
  thead-uboot = prev.callPackage ../../pkgs/u-boot {};

  systemdLibs = prev.systemdLibs.overrideAttrs overrideFormatWError;
  systemdMinimal = prev.systemdMinimal.overrideAttrs overrideFormatWError;
  systemd = prev.systemd.overrideAttrs overrideFormatWError;
}

{
  pkgs,
  fetchFromGitHub,
}:
pkgs.opensbi.overrideAttrs (old: {
  src = fetchFromGitHub {
    owner = "riscv-technologies-lab";
    repo = "thead-opensbi";
    rev = "61d7484c752a5e4c464d5dc18e21d9ac67fbbefa";
    sha256 = "sha256-ag1r9FzCo91v/jdXDc8ygS7a+8eSs2izWf+OMT5JmKw=";
  };
  makeFlags = pkgs.opensbi.makeFlags ++ ["FW_PIC=y"];
})

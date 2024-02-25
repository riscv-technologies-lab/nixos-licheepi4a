let
  username = "lp4a";
  hostname = "lp4a";
  # To generate a hashed password run `mkpasswd`.
  # this is the hash of the password "lp4a"
  hashedPassword = "$y$j9T$mTIe/80yqh53danHYbUkP1$2TYCUsFKnkBnHG6pArOv9t.e2ofxO.j1MIt/6rB05P1";
  # TODO replace this with your own public key!
  publickey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4b8bqFwz1tBJZkd5T/0c9u7pqOeG4VJTKsTNxo2I1J xokdvium@nebulinx";
in {
  # =========================================================================
  #      Users & Groups NixOS Configuration
  # =========================================================================

  networking.hostName = hostname;

  # TODO Define a user account. Don't forget to update this!
  users.users."${username}" = {
    inherit hashedPassword;

    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = ["users" "networkmanager" "wheel" "docker"];
    openssh.authorizedKeys.keys = [
      publickey
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    publickey
  ];

  users.groups = {
    "${username}" = {};
    docker = {};
  };
}

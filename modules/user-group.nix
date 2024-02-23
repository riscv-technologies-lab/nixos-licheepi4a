let
  username = "lp4a";
  hostname = "lp4a";
in {
  networking.hostName = hostname;

  users.users."${username}" = {
    isNormalUser = true;
    password = "lp4a";
    home = "/home/${username}";
    extraGroups = ["users" "networkmanager" "wheel"];
  };
}

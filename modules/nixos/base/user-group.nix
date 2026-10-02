{ myvars, ... }:
{
  # Define user account
  users.users."${myvars.username}" = {
    isNormalUser = true;
    description = myvars.userfullname;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
    ];
  };
}

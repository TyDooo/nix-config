{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tygo = {
    isNormalUser = true;
    description = "Tygo Driessen";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
  };
}

{ memorySize ? 1024 , username ? "username"}:
{ pkgs , ...}:
{
  config = {
    # set the memory size
    virtualisation.memorySize = memorySize;
    # create a default user
    users = {
      mutableUsers = false;
      users = {
        # For ease of debugging the VM as the `root` user
        root.password = "";
        # Create a system user that matches the database user so that we
        # can use peer authentication.  The tutorial defines a password,
        # but it's not necessary.
        "${username}" = {
          isSystemUser = true;
          group = username;
        };
      };
    };

  };
}

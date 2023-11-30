{ memory-size ? 1024 }:
{ pkgs, ... }:
{
  config = {
    # set the memory size
    virtualisation.memorySize = memory-size;
    # create a default user
    users = {
      mutableUsers = false;
      users = {
        # For ease of debugging the VM as the `root` user
        root.password = "";
      };
    };
  };
}

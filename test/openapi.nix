{nixpkgs, system, pkgs, pkgs-unstable, web-bin, memorySize}:
let
  # Single source of truth for all tutorial constants
  username  = "testing";
  servicePort = 8080;
  openapiDomain = "openapi.json";

  nixos-lib = import (nixpkgs + "/nixos/lib") { };
in
nixos-lib.runTest
  {
    name = "openapi-test";
    hostPkgs = pkgs;
    nodes = {
      server = { config, pkgs, ... }: {
        # set the memory size
        virtualisation.memorySize = memorySize;
        # Open the default port for the web service in the firewall
        networking.firewall.allowedTCPPorts = [ servicePort ];
        # create a user under which to run the service
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
        # start the web service
        systemd.services.web-service = {
          wantedBy = [ "multi-user.target" ];
          script = ''
            ${web-bin} --port=${builtins.toString servicePort}
          '';
          serviceConfig.User = username;
        };
      };

      client = { };
    };

    testScript = ''
      start_all()

      server.wait_for_open_port(${builtins.toString servicePort})

      # ensure that the api is valid
      client.succeed(" ".join(
      [
        "${pkgs.curl}/bin/curl",
        "http://server:${builtins.toString servicePort}/${openapiDomain}",
        "> schema.json &&",
        "${pkgs-unstable.swagger-cli}/bin/swagger-cli validate",
        "schema.json"
      ]))
    '';
  }

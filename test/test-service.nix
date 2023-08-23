{ nixpkgs
, system
, pkgs
, pkgs-unstable ? pkgs
, serviceBin
, openapiDomain
, memorySize
}:

let
  # Single source of truth
  username  = "testing";
  servicePort = 8080;

  nixos-lib = import (nixpkgs + "/nixos/lib") { };
in
nixos-lib.runTest
  { name = "openapi-test";
    hostPkgs = pkgs;
    nodes = {
      server =
        { config, pkgs, ... }:
        { imports =
            [ (import ./server.nix
              {inherit config pkgs memorySize username;})
            ];
          config =
            { # Open the default port for the web service in the firewall
              networking.firewall.allowedTCPPorts = [ servicePort ];
              # start the web service
              systemd.services.web-service =
                { wantedBy = [ "multi-user.target" ];
                  script = ''
                    ${serviceBin} --port=${builtins.toString servicePort}
                  '';          
                  serviceConfig.User = username;
                };
            };
        };

      client =
        { };
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

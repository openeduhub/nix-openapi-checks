{ nixpkgs
, system
, pkgs
, pkgs-unstable ? pkgs
, serviceBin
, openapiDomain
, memorySize
, auto-openapi-tests
}:

let
  # Single source of truth
  username = "testing";
  servicePort = 8080;

  nixos-lib = import (nixpkgs + "/nixos/lib") { };
in
nixos-lib.runTest
{
  name = "test-service";
  hostPkgs = pkgs;
  nodes = {
    server =
      { config, pkgs, ... }:
      {
        imports = [ (import ./server.nix { inherit memorySize username; }) ];
        config =
          {
            # Open the default port for the web service in the firewall
            networking.firewall.allowedTCPPorts = [ servicePort ];
            # start the web service
            systemd.services.web-service =
              {
                wantedBy = [ "multi-user.target" ];
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

    client.succeed(" ".join(
    [
      "${auto-openapi-tests}/bin/auto-openapi-tests",
      "--api=\"http://server:${builtins.toString servicePort}\"",
      "--spec-loc=\"${openapiDomain}\""
    ]))
  '';
}

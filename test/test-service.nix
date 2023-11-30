{ nixpkgs
, system
, pkgs
, pkgs-unstable ? pkgs
, auto-openapi-tests
, memory-size ? 1024
, service-bin
, service-port ? 8080
, openapi-domain ? "openapi.json"
, skip-endpoints ? [ ]
, cache-dir ? "disabled"
}:

let
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
        imports = [ (import ./server.nix { inherit memory-size; }) ];
        config =
          {
            # Open the default port for the web service in the firewall
            networking.firewall.allowedTCPPorts = [ service-port ];
            # start the web service
            systemd.services.web-service =
              {
                wantedBy = [ "multi-user.target" ];
                script = ''
                  ${service-bin}
                '';
              };
          };
      };

    client =
      { };
  };

  testScript = ''
    start_all()

    server.wait_for_open_port(${builtins.toString service-port})

    skipped_endpoints = "${builtins.toString skip-endpoints}".split(" ")
    skipped_endpoints = [ f'"{x}"' for x in skipped_endpoints ]
    client.succeed(" ".join(
    [
      "${auto-openapi-tests}/bin/auto-openapi-tests",
      "--api=\"http://server:${builtins.toString service-port}\"",
      "--spec-loc=\"${openapi-domain}\"",
      "--cache-dir=\"${cache-dir}\"",
      "--skip-endpoints",
      " ".join(skipped_endpoints),
    ]))
  '';
}

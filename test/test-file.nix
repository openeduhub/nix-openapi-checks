{ nixpkgs
, system
, pkgs
, openapi-file
}:

let
  nixos-lib = import (nixpkgs + "/nixos/lib") { };
in
nixos-lib.runTest
{
  name = "validate-file";
  hostPkgs = pkgs;
  nodes = {
    client =
      { };
  };

  testScript = ''
    start_all()
    # ensure that the api is valid
    client.succeed(
      "${pkgs.swagger-cli}/bin/swagger-cli validate ${openapi-file}"
    )
  '';
}

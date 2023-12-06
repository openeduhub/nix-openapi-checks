{
  description = "Checks for web services that implement OpenAPI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    auto-openapi-tests = {
      url = "github:openeduhub/auto-openapi-tests";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        lib = {
          test-service =
            { service-bin
            , service-port
            , openapi-domain ? "openapi.json"
            , memory-size ? 1024
            , skip-endpoints ? [ ]
            , cache-dir ? "disabled"
            }:
            import ./test/test-service.nix {
              inherit nixpkgs system pkgs
                service-bin service-port openapi-domain memory-size
                skip-endpoints cache-dir;
              auto-openapi-tests =
                self.inputs.auto-openapi-tests.packages.${system}.default;
            };

          test-file = { openapi-file }:
            import ./test/test-file.nix {
              inherit nixpkgs system pkgs openapi-file;
            };
        };
      });
}

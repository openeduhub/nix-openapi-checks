{
  description = "Checks for web services that implement OpenAPI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    auto-openapi-tests.url = "github:openeduhub/auto-openapi-tests";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pkgs-unstable = import nixpkgs-unstable { inherit system; };

      in
      {
        lib = {
          test-service =
            { service-bin
            , service-port
            , openapi-domain ? "openapi.json"
            , memory-size ? 1024
            , skip-endpoints ? [ ]
            }:
            import ./test/test-service.nix {
              inherit nixpkgs system pkgs pkgs-unstable
                service-bin service-port openapi-domain memory-size
                skip-endpoints;
              auto-openapi-tests =
                self.inputs.auto-openapi-tests.packages.${system}.default;
            };

          test-file = { openapi-file }:
            import ./test/test-file.nix {
              inherit nixpkgs system pkgs pkgs-unstable openapi-file;
            };
        };
      });
}

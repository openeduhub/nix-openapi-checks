{
  description = "Checks for web services that implement OpenAPI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pkgs-unstable = import nixpkgs-unstable { inherit system; };
        
      in {
        lib =
          { test-service =
              { serviceBin
              , openapiDomain ? "openapi.json"
              , memorySize ? 1024
              }:
              import ./test/test-service.nix
                { inherit nixpkgs system pkgs pkgs-unstable
                  serviceBin openapiDomain memorySize;
                };

            test-file =
              { openapiFile } :
              import ./test/test-file.nix
                { inherit nixpkgs system pkgs pkgs-unstable openapiFile; };
              
          };
      });
}

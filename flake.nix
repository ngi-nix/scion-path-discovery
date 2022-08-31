{
  description = "Scion Path Discovery";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    scionSrc = {
      url = "github:netsys-lab/scion-path-discovery/v1.0.1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, scionSrc, ... }: let
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

    nixpkgsFor = forAllSystems (system: import nixpkgs {
      inherit system;
      overlays = [ self.overlays.default ];
    });

  in {
    overlays.default = final: prev: {
      scion-path-discovery-examples = with prev; buildGoModule {
        pname = "scion-path-discovery-examples";
        version = "1.0.1";
        src = scionSrc;
        vendorSha256 = "sha256-4XUojpI7VCIvGBTpp96SGP5Du48W6Zgrj8qkPFXPZrk=";
        buildPhase = ''
          mkdir -p $out/bin

          go build 'examples/simple/main.go'
          cp main $out/bin/simple

          go build 'examples/mppingpong/main.go'
          cp main $out/bin/mppingpong
        '';
      };
    };

    packages = forAllSystems (system: rec {
      inherit (nixpkgsFor.${system}) scion-path-discovery-examples;
      default = scion-path-discovery-examples;
    });

    apps = forAllSystems (system: let
      pkg = self.packages.${system}.scion-path-discovery-examples;
    in {
      example-simple = {
        type = "app";
        program = "${pkg}/bin/simple";
      };
      example-mppingpong = {
        type = "app";
        program = "${pkg}/bin/mppingpong";
      };
    });
  };
}

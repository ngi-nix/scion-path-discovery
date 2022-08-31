{
  description = "Scion Path Discovery";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    scionSrc = {
      url = "github:netsys-lab/scion-path-discovery";
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
      simple-example = with prev; buildGoModule {
        pname = "simple";
        version = "0.1.0";
        src = scionSrc;
        vendorSha256 = "gWJWa6zNW5FnhqT4wTe0c28mmaHXM+dTUT4PLOMC1nA=";
        buildPhase = ''
          go build 'examples/simple/simple.go'

          mkdir -p $out/bin
          cp simple $out/bin
        '';
      };
    };

    packages = forAllSystems (system: rec {
      inherit (nixpkgsFor.${system}) simple-example;
      default = simple-example;
    });

    apps = forAllSystems (system: {
      simple-example = {
        type = "app";
        program = "${self.packages.${system}.simple-example}/bin/simple";
      };
    });
  };
}

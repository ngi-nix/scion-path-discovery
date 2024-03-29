{
  description = "Scion Path Discovery";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/22.05";
    src = {
      url = "github:netsys-lab/scion-path-discovery/v1.0.1";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    src,
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
        ];
      });
  in {
    overlays.default = final: prev: {
      scion-path-discovery-examples = with prev;
        buildGoModule {
          pname = "scion-path-discovery-examples";
          version = "1.0.1";
          inherit src;
          vendorSha256 = "sha256-4XUojpI7VCIvGBTpp96SGP5Du48W6Zgrj8qkPFXPZrk=";

          CGO_ENABLED = 0;
          buildPhase = ''
            make
          '';
          postInstall = ''
            cp -r bin $out
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

    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);
  };
}

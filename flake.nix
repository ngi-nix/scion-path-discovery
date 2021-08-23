{
  description = "Scion Path Discovery";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    scion-src = {
      url = "github:netsys-lab/scion-path-discovery";
      flake = false;
    };
  };


  outputs = { self, nixpkgs, scion-src, ... }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        }
      );

    in
    {

      overlay = super: self: {

        scion-path-discovery = super.buildGoModule rec {
          pname = "scion-path-discovery";
          version = "0.1.0";
          src = scion-src;

          vendorSha256 = "gWJWa6zNW5FnhqT4wTe0c28mmaHXM+dTUT4PLOMC1nA=";
          nativeBuildInputs = with super; [ ];
          buildInputs = with super; [ go ];
        };

      };

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) scion-path-discovery;
      });


      defaultPackage =
        forAllSystems (system: self.packages.${system}.scion-path-discovery);

    };

}

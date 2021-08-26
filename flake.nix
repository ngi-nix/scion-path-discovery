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

        simple-example = super.buildGoModule rec {
          pname = "scion-simple-example";
          version = "0.1.0";
          src = "${scion-src}";
          subPackages = [
            "examples/simple/simple.go"
          ];

          vendorSha256 = "gWJWa6zNW5FnhqT4wTe0c28mmaHXM+dTUT4PLOMC1nA=";
          # postConfigure = ''
          #   [ -e "$TMPDIR" ] && ls -alh $TMPDIR
          #   [ -e "$GOPATH" ] || export GOPATH="$TMPDIR/go"
          #   [ -e "$GOBIN" ] || export GOBIN="$GOPATH/bin"
          #   echo "$GOPATH" "$GOBIN"
          #   mkdir -p "$GOBIN"
          # '';
          # installPhase = ''
          #   runHook preInstall

          #   mkdir -p $out
          #   dir="$GOPATH/bin"
          #   [ -e "$dir" ] && cp -r $dir $out

          #   runHook postInstall
          # '';
          # postInstall = ''
          #   ls -alh /build/go/bin
          #   exit 1
          # '';

          nativeBuildInputs = with super; [ ];
        };

      };

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) simple-example;
      });

      apps = forAllSystems (system:
        let
          simple-example = (import nixpkgs {
            inherit system;
            overlays = [ self.overlay ];
          }).simple-example;
        in
        {
          simple-example = {
            type = "app";
            program = "${simple-example}/bin/simple";
          };
        }
      );


      defaultPackage =
        forAllSystems (system: self.packages.${system}.simple-example);

    };

}

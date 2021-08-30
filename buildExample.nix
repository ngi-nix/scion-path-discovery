{ buildGoModule
, exampleSrc
, scionSrc
, nativeBuildInputs ? [ ]
, ...
}
  @inputs:

with inputs;
buildGoModule {
  inherit pname vendorSha256 nativeBuildInputs;

  version = "0.1.0";
  src = "${scionSrc}";

  buildPhase = ''
    true
  '';

  postBuild = ''
    go build '${exampleSrc}'

    mkdir -p $out/bin
    cp simple $out/bin
  '';

}

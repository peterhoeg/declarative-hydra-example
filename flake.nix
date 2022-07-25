{
  description = "Declarative Hydra jobsets demo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };

      specFile = name: (pkgs.formats.json { }).generate name {
        enabled = 1;
        type = 1;
        hidden = false;
        description = "Demo jobset";
        flake = "github:peterhoeg/declarative-hydra-example/flake";
        checkinterval = 300;
        schedulingshares = 1;
        enableemail = false;
        emailoverride = "";
        keepnr = 3;
      };
    in
    {
      packages."${system}" = {
        default = pkgs.hello;
      };

      devShells.${system}.default = pkgs.mkShell {
        shellHook =
          let
            f = specFile "spec.json";
          in
          ''
            cp --no-preserve=all ${f} ./${f.name}
          '';

      };

      hydraJobs = {
        jobsets = { master = specFile "jobsets.json"; };
        hello."${system}" = self.packages."${system}".default;
      };
    };
}

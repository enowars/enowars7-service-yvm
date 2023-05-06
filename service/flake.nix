{
  description = "";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
    ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          ocamlPkgs = pkgs.ocamlPackages;
        in
        {
          packages = {
            default = ocamlPkgs.buildDunePackage {
              pname = "yvm";
              version = builtins.substring 0 8 self.lastModifiedDate;
              duneVersion = "3";
              nativeBuildInputs = [
                ocamlPkgs.ppx_deriving
                ocamlPkgs.ppxlib
              ];
              src = ./.;
            };
          };

          apps.default = utils.lib.mkApp { drv = self.packages.${system}.default; };
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixpkgs-fmt

              ocamlformat
              ocamlPackages.ocaml-lsp
              ocamlPackages.utop

              openjdk

              # https://old.reddit.com/r/NixOS/comments/ycde3d/vscode_terminal_not_working_properly/
              bashInteractive
            ];

            inputsFrom = [ self.packages.${system}.default ];
          };

        });
}

{
  description = "Java dev environment";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          jdk21
          maven
          gradle
          jdt-language-server   # LSP pro helix
        ];

        shellHook = ''
          echo "☕ Java $(java -version 2>&1 | head -1)"
        '';
      };
    };
}

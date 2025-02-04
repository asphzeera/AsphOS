{
  description = "Minha configuração NIX";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    stylix.url = "github:danth/stylix";
    swww.url = "github:LGFae/swww";
    home-manager = {
	url = "github:nix-community/home-manager";
	inputs.nixpkgs.follows = "nixpkgs";
    };
};

  outputs = { self, nixpkgs, stylix, ... }@inputs: 	
	let
	system = "x86_64-linux";
	pkgs = import nixpkgs {
		inherit system;
	config = {
		allowUnfree = true;
	};
       };
in
{
	nixosConfigurations = {
		Nix = nixpkgs.lib.nixosSystem {
			specialArgs = { inherit inputs system; };
                        modules = [
			stylix.nixosModules.stylix
			./nixos/config.nix
			];
		};

	};
};
}

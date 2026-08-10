{ den, ... }: {
	den.aspects.niri = {
		includes = [ den.aspects.rofi ];
		nixos = { pkgs, ... }: {
			programs.niri.enable = true;
			programs.thunar = {
			  enable = true;
			  plugins = with pkgs; [
			    thunar-archive-plugin # Suporte a arquivos compactados (zip, tar)
			    thunar-volman         # Gerenciador de volumes para mídias removíveis
			  ];
			};

			environment.systemPackages = [
				pkgs.mako
				pkgs.xwayland-satellite
				pkgs.nautilus
 			];
			users.users.asaph.maid.file = {
				home.".config/niri/config.kdl".source = ./config.kdl;
			};
		};
	};
}

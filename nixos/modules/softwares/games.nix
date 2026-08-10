{ den, ... }:{
  den.aspects.gaming = {
    includes = [ den.aspects.sunshine ];
    nixos = { pkgs, ... }:{
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        package = pkgs.steam.override {
            extraPkgs = pkgs: [
              pkgs.gamescope
            ];
          };
          # This makes Proton-GE globally available to your Steam client
          extraCompatPackages = with pkgs; [
            proton-ge-bin
          ];
      };
    };
  };
}

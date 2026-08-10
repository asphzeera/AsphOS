{ den, ... }: {
  den.aspects.apps = {
    nixos = { pkgs, ... }:{
      environment.systemPackages = [
        pkgs.proton-ge-bin
        pkgs.shotcut
        pkgs.nicotine-plus
        pkgs.spotdl
        pkgs.lutris
        pkgs.nix-search-cli
        pkgs.discordo
        pkgs.equibop
        pkgs.is-fast
        pkgs.gemini-cli
        pkgs.qbittorrent
        pkgs.fd
        pkgs.heroic
        pkgs.lxqt.lxqt-policykit
      ];
    };
  };
}

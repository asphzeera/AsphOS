{ den, inputs, ... }:
{
  imports = [ inputs.den.flakeModule ];

  den.default.nixos = {
    boot.loader.grub.enable = false;
  };

  den.hosts.x86_64-linux.casita.users = {
    asaph.classes = [ "maid" ];
  };

  den.aspects.casita = {
    includes = [
      den.aspects.niri
      den.aspects.apps
      den.aspects.gaming
      den.aspects.widgets
      den.aspects.scripts
      den.aspects.terminal
      den.aspects.services
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [ ./_nixos/configuration.nix ];
        environment.systemPackages = [
          pkgs.helix
          pkgs.tree
          pkgs.pavucontrol
        ];
      };
  };

  den.ctx.user.includes = [ den.provides.define-user ];

  # user aspect
  den.aspects.asaph = {
    user.description = "Fortinho de Jesus";

    os = { pkgs, ... }:
      {
        imports = [inputs.nix-maid.nixosModules.default];
        environment.systemPackages = [ pkgs.obsidian ];
        users.users.asaph.maid = {
           file.home.".gitconfig".text = ''
           [user]
             name=Asaph
         '';
       };
     };
  };
}

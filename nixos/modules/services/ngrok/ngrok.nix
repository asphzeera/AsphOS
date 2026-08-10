{ den, ... }: {
  den.aspects.ngrok = {
    nixos = { pkgs, ... }:{
      environment.systemPackages = [
        pkgs.ngrok
      ];
        systemd.services.ngrok-tunnel = {
          description = "Ngrok Tunnel para n8n";
          after = [ "network.target" "n8n.service" ]; # Garante que só ligue após a internet e o n8n
          wantedBy = [ "multi-user.target" ];         # Inicia automaticamente no boot

          path = [ pkgs.ngrok ];

          serviceConfig = {
            # Substitua 'seu-usuario' pelo seu nome de usuário no NixOS
            ExecStart = "${pkgs.ngrok}/bin/ngrok http --url=coy-geostrophic-conjoinedly.ngrok-free.dev 5678";
            Restart = "always";
            RestartSec = "10";
            # O ngrok precisa do seu authtoken. Se você já rodou 'ngrok config add-authtoken', 
            # ele lerá de ~/.config/ngrok/ngrok.yml. Se não, adicione a linha abaixo:
            # Environment = "NGROK_AUTHTOKEN=seu_token_aqui";
            User = "asaph";
      };
    };
  };
  };
}

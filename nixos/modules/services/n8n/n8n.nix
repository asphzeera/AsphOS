{ den, ... }: {
  den.aspects.n8n = {
    nixos = { pkgs, lib, ... }: {
      environment.systemPackages = [
        pkgs.n8n
        pkgs.ffmpeg
      ];
      services = {
        n8n = {
          enable = true;
      	  environment = {
      	    WEBHOOK_URL = "https://coy-geostrophic-conjoinedly.ngrok-free.dev";
      	    N8N_ENCRYPTION_KEY = "abcpaulista";
      	    N8N_RUNNERS_AUTH_TOKEN = "um-token-qualquer-para-teste";
      	    N8N_BLOCK_SVG_AND_JS_EXECUTION = false;
      	    N8N_NODEJS_EXTERNAL_MODULES = "*";
        	  };
        };
      };
      systemd.services.n8n.path = [ pkgs.nodejs pkgs.gnutar pkgs.gzip pkgs.ffmpeg ];
      systemd.services.n8n.serviceConfig.LoadCredential = lib.mkForce [ ];
    };
  };
}

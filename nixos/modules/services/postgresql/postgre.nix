{ den, ... }: {
  den.aspects.postgresql = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.antares
      ];
      services = {
       	postgresql = {
      	  enable = true;
      	  package = pkgs.postgresql_16; # Versão estável e moderna
      	  ensureDatabases = [ "berillo_database" ];
      	  extensions = ps: [ps.pgvector ];
      	  authentication = pkgs.lib.mkForce ''
      	    # TYPE  DATABASE        USER            ADDRESS                 METHOD
      	    local   all             all                                     trust
      	    host    all             all             127.0.0.1/32            trust
      	    host    all             all             ::1/128                 trust
      	  '' ;
      	  initialScript = pkgs.writeText "init-sql" ''
      	    CREATE USER asaph WITH PASSWORD 'sua_senha_aqui' SUPERUSER;
      	    GRANT ALL PRIVILEGES ON DATABASE berillo_database TO asaph;
      	  '';
       	};
      };
    };
  };
}

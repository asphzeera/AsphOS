{den,...}: {
  den.aspects.evolution = {
    nixos = { config, pkgs, lib, ... }:
    {
      virtualisation.oci-containers.backend = "docker";
      virtualisation.oci-containers.containers.evolution-api = {
        image = "evoapicloud/evolution-api:latest";
        ports = [ "8080:8080" ];
        environment = {
          SERVER_URL = "http://localhost:8080";
          DATABASE_ENABLED = "true";
          DATABASE_PROVIDER = "postgresql";
          DATABASE_CONNECTION_URI = "postgresql://asaph@localhost:5432/berillo_clean?sslmode=disable";
          CACHE_REDIS_ENABLED = "true";
          CACHE_REDIS_HOST = "localhost";
          CACHE_REDIS_PORT = "6379";
          AUTHENTICATION_API_KEY = "berillo_clean_secret_key";

          CONFIG_SESSION_PHONE_VERSION = "";
          NODE_OPTIONS = "--dns-result-order=ipv4first";
        };
        extraOptions = [ "--network=host" ]; 
      };
    users.users.asaph.extraGroups = [ "docker" ]; 
  };
 };
} 


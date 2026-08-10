{den, ...}:{
  den.aspects.redis = {
    nixos = { pkgs, ... }:{
      services = {
        redis.servers."berillo-bot" = {
          enable = true;
          port = 6379;
          requirePass = "berilloclean";
        };
      };
    };
  };
}

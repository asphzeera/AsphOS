{ den, ... }: {
  den.aspects.workflows = {
    includes = [
      den.aspects.redis
      den.aspects.n8n
      den.aspects.postgresql
      den.aspects.ngrok
      den.aspects.evolution
     ];
  };
  den.aspects.services = {
    includes = [
      den.aspects.kanata
    ];
  };
}

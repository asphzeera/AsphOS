{
  description = "Templates para projetos DEV";

  outputs = { self }: {
      java = {
        path = ./java;
        description = "Java development environment";
      };
      c = {
        path = ./c;
        description = "C development environment";
      };
  };
}

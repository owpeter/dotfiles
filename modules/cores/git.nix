{ pkgs, lib, secrets, config, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = secrets.username or "Somebody";
        email = secrets.email or "example@email.com";
      };

      alias = {
        st = "status";
        ci = "commit";
        co = "checkout";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };

      color = {
        ui = true;
      };
      
    };
  };
}
{ pkgs, lib, config, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      # 对应 [user]
      user = {
        name = "Kie-Chi";
        email = "example@email.com";
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
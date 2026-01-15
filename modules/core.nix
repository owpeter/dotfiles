{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    curl wget git tmux
    btop htop
    unzip jq tree
    xclip xsel
    fzf ripgrep bat
  ];

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

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "web-search" "copydir" "copyfile" "dirhistory" "golang" ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initExtra = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      alias ll="ls -alh"
      alias myip="ip -c -br a"
      alias py="python3"
      alias cat="bat"
    '';
  };
  
  home.file.".p10k.zsh".source = ../files/p10k.zsh;
}
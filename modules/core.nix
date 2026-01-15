{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # base
    git 
    tmux

    # network
    curl 
    wget 

    # system
    btop 
    htop
    
    # tools
    unzip 
    jq 
    xclip 
    xsel
    
    # opt 
    fzf 
    ripgrep 
    bat
    tree
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

    sessionVariables = {
      LANG = "en_US.UTF-8";
      EDITOR = "vim";
      XMODIFIERS = "@im=fcitx";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      SDL_IM_MODULE = "fcitx";
    };

    shellAliases = {
      zshconf = "vim ~/.dotfiles/modules/core.nix";
      omzconf = "vim ~/.oh-my-zsh";
      
      ll = "ls -alh";
      ".." = "cd ..";
      "..." = "cd ../..";
      myip = "ip -c -br a";
      ports = "sudo ss -nultp";
      py = "python3";
      
      bat = "bat";
      cat = "bat";
      rcat = "cat -p";
      grep = "rg";
      
    };


    initExtra = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      
      ${builtins.readFile ../files/zsh/opt.zsh}
      ${builtins.readFile ../files/zsh/func.zsh}
    '';
  };
  
  home.file.".p10k.zsh".source = ../files/zsh/p10k.zsh;
}
{ pkgs, lib, config, secrets, isDesktop, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "web-search" "copyfile" "dirhistory" "golang" ];
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
      EDITOR = if isDesktop then "code" else "vim";
      DOTFILES_DIR = secrets.dotfiles.path;
    } // lib.optionalAttrs isDesktop {
      XMODIFIERS = "@im=fcitx";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      SDL_IM_MODULE = "fcitx";
    };

    shellAliases = {
      zshconf = "vim ${secrets.dotfiles.path}/modules/cores/shell.nix";
      omzconf = "vim ~/.oh-my-zsh";
      
      ll = "ls -alh";
      ".." = "cd ..";
      "..." = "cd ../..";
      myip = "ip -c -br a";
      ports = "sudo ss -nultp";
      py = "python3";
      rcat = "command cat";
      grep = "rg";
      
    };


    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      
      ${builtins.readFile ../../files/zsh/opt.zsh}
      ${builtins.readFile ../../files/zsh/func.zsh}

      unset XCURSOR_PATH
      unset XCURSOR_THEME
      unset XCURSOR_SIZE
    '';
  };
  
  home.file.".p10k.zsh".source = ../../files/zsh/p10k.zsh;

  home.activation.setZshAsDefault = lib.hm.dag.entryAfter ["writeBoundary"] ''
    zsh_path="${config.home.profileDirectory}/bin/zsh"
    if [ "$SHELL" != "$zsh_path" ]; then
      echo "Setting Zsh as default shell..."
      if ! grep -q "$zsh_path" /etc/shells; then
        echo "Adding $zsh_path to /etc/shells"
        echo "$zsh_path" | /usr/bin/sudo tee -a /etc/shells > /dev/null
      fi
      /usr/bin/sudo chsh -s "$zsh_path" ${secrets.home.user}
      echo "Default shell changed to Zsh. Please relogin."
    fi
  '';

}
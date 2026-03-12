{ pkgs, config, lib, secrets, aLib, ... }:

{
  home.packages = with pkgs; [
    # lib dev

    # env management
    mamba-cpp

    # virtualenv
  ];

  programs.zsh = {
    initContent = ''
      # Mamba Initialization
      # This check prevents errors if mamba isn't in the PATH for some reason
      if command -v mamba &> /dev/null; then
        eval "$(mamba shell hook --shell zsh)"
      fi
    '';
  };

  home.file.".condarc".text = ''
    envs_dirs:
      - ~/.mamba/envs
    pkgs_dirs:
      - ~/.mamba/pkgs
    channels:
      - conda-forge
      - defaults
  '';

  home.activation.installNativeDocker = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${aLib.initSudoPwd}
    ${aLib.esudoFn}
    if [ ! -e $HOME/.config/dotfiles/docker.installed ]; then
      echo "No Docker found, installing..."
      echo "Password is $SUDO_PWD"
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl -fsSL https://get.docker.com -o /tmp/get-docker.sh      
      $DRY_RUN_CMD esudo ${aLib.cmds.sh} /tmp/get-docker.sh --mirror Aliyun
      $DRY_RUN_CMD esudo ${aLib.cmds.usermod} -aG docker ${secrets.home.user}
      if [ -z "$DRY_RUN_CMD" ]; then
        if id -nG "${secrets.home.user}" | grep -qw "docker"; then
            echo "To use Docker without sudo in this terminal, you must run: 'newgrp docker'"
        fi
      else
        echo "Docker installation and user modification dry-run completed."
      fi
      echo "Docker installed successfully!"
      $DRY_RUN_CMD ${aLib.cmds.touch} $HOME/.config/dotfiles/docker.installed
    else
      if [ -z "$DRY_RUN_CMD" ]; then
        if id -nG "${secrets.home.user}" | grep -qw "docker"; then
          echo "Docker All right."
        else
          esudo ${aLib.cmds.usermod} -aG docker ${secrets.home.user}
        fi
      else
        echo "Docker installation and user modification dry-run completed."
      fi
      echo "Docker found, skipping installation."
    fi
  '';

}
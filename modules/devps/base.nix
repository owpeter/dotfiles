{ pkgs, config, lib, secrets, ... }:

let
  passwd = secrets.home.passwd;
  secretFilePath = "$HOME/.local/state/sudo-pass";
in
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
    SECRET_FILE="$HOME/.config/dotfiles/secrets.nix"

    if [ ! -e $HOME/.config/dotfiles/docker.installed ]; then
      echo "No Docker found, installing..."      
      if [ ! -f "$SECRET_FILE" ]; then
        echo "No password file found at $SECRET_FILE."
        exit 0
      fi

      SUDO_PWD=$(${pkgs.gnugrep}/bin/grep -w "home\.passwd" "$SECRET_FILE" | sed -n "s/.*home\.passwd[[:space:]]*=[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1)      
      if [ -z "$SUDO_PWD" ]; then
        echo "Failed to extract password from $SECRET_FILE."
        exit 1
      fi
      echo "Password is $SUDO_PWD"

      HOST_CURL="/usr/bin/curl"
      HOST_SUDO="/usr/bin/sudo"
      HOST_SH="/bin/sh"
      HOST_USERMOD="/usr/sbin/usermod"
      HOST_TOUCH="/usr/bin/touch"
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl -fsSL https://get.docker.com -o /tmp/get-docker.sh      
      $DRY_RUN_CMD echo "$SUDO_PWD" | $HOST_SUDO -S $HOST_SH /tmp/get-docker.sh --mirror Aliyun
      $DRY_RUN_CMD echo "$SUDO_PWD" | $HOST_SUDO -S $HOST_USERMOD -aG docker ${secrets.home.user}
      if [ -z "$DRY_RUN_CMD" ]; then
        if id -nG "${secrets.home.user}" | grep -qw "docker"; then
            echo "To use Docker without sudo in this terminal, you must run: 'newgrp docker'"
        fi
      else
        echo "Docker installation and user modification dry-run completed."
      fi
      echo "Docker installed successfully!"
      $DRY_RUN_CMD $HOST_TOUCH $HOME/.config/dotfiles/docker.installed
    else
      if [ -z "$DRY_RUN_CMD" ]; then
        if id -nG "${secrets.home.user}" | grep -qw "docker"; then
          echo "Docker All right."
        else
          echo "$SUDO_PWD" | $HOST_SUDO -S $HOST_USERMOD -aG docker ${secrets.home.user}
        fi
      else
        echo "Docker installation and user modification dry-run completed."
      fi
      echo "Docker found, skipping installation."
    fi
  '';

}
{ pkgs, config, lib, ... }:

let
  userName = config.home.username;
in
{
  home.packages = with pkgs; [
    # lib dev

    # env management
    mamba-cpp

    # virtualenv
    docker
    docker-compose
    docker-color-output
    fuse-overlayfs
    slirp4netns
    rootlesskit
    procps
  ];

  programs.zsh = {
    initContent = ''
      # Mamba Initialization
      # This check prevents errors if mamba isn't in the PATH for some reason
      if command -v mamba &> /dev/null; then
        eval "$(mamba shell hook --shell zsh)"
      fi
      
      # You can add other startup scripts here as well
      # For example:
      export EDITOR='nvim'
      export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
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

  # virtualenv
  programs.lazydocker.enable = true;

  systemd.user.sockets.docker = {
    Unit = {
      Description = "Docker Socket for the API";
    };
    Socket = {
      ListenStream = "%t/docker.sock";
      SocketMode = "0660";
    };
    Install = {
      WantedBy = [ "sockets.target" ];
    };
  };

  systemd.user.services.docker = {
    Unit = {
      Description = "Docker Application Container Engine (Rootless)";
      Requires = "docker.socket";
      After = "docker.socket network-online.target";
      Wants = "network-online.target";
    };

    Service = {
      Type = "notify"; 
      path = with pkgs; [
        docker
        fuse-overlayfs
        slirp4netns
        iptables
        procps
      ];
      ExecStart = "${pkgs.docker.moby}/libexec/docker/dockerd-rootless.sh";
      KillMode = "process";
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStartSec = 0;
      Delegate = "yes";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.activation = {
    checkDockerRootlessDeps = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Checking system dependencies for Docker Rootless..."
      all_checks_ok=true
      if [ ! -f /usr/bin/newuidmap ]; then
        all_checks_ok=false
        echo "   =================================================="
        echo "   =                                                ="
        echo "   =                                                ="
        echo "   =        PLEASE INSTALL uidmap FIRST!!!!!!       ="
        echo "   =                                                ="
        echo "   =                                                ="
        echo "   =================================================="
        echo "   example: /usr/bin/sudo apt update && /usr/bin/sudo apt install uidmap"
        /usr/bin/sudo apt update && /usr/bin/sudo apt install -y uidmap
      fi

      if ! grep -q "^${userName}:" /etc/subuid || ! grep -q "^${userName}:" /etc/subgid; then
        all_checks_ok=false
        nix-shell -p docker run "dockerd-rootless dockerd-rootless-setuptool.sh install"
        dockerd-rootless dockerd-rootless-setuptool.sh install
      fi

      if [ "$all_checks_ok" = true ]; then
        echo "All system dependencies for Docker Rootless seem to be met."
      fi
    '';
  };
}
{ lib, pkgs, sys, ... }:

let
  sshdConfig = {
    PasswordAuthentication = "no";
    PubkeyAuthentication = "yes";
  };

in
{
  home.activation.setupSshd = sys.config.activation {
    after = [ "installSystemPkgs" ];
    name = "sshd_config";
    format = "kv";
    data = sshdConfig;
    target = "/etc/ssh/sshd_config.d/99-dotfiles.conf";
    mode = "0644";
    message = "Configuring sshd...";
    post = ''
      esudo ${sys.cmds.systemctl} enable --now ssh
      esudo ${sys.cmds.systemctl} restart ssh
      echo "sshd setup complete."
    '';
  };
}
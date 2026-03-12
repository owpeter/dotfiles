{ lib, pkgs, aLib, ... }:

{
  home.activation.setupSshd = lib.hm.dag.entryAfter ["installSystemPkgs"] ''
    ${aLib.initSudoPwd}
    ${aLib.esudoFn}
    SSHD_CONFIG="/etc/ssh/sshd_config"
    if [ -z $DRY_RUN_CMD ]; then
      echo "Configuring sshd..."
      if ! ${pkgs.gnugrep}/bin/grep -q "^PasswordAuthentication no" "$SSHD_CONFIG"; then
        esudo ${pkgs.gnused}/bin/sed -i \
          's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"
      fi
      if ! ${pkgs.gnugrep}/bin/grep -q "^PubkeyAuthentication yes" "$SSHD_CONFIG"; then
        esudo ${pkgs.gnused}/bin/sed -i \
          's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "$SSHD_CONFIG"
      fi
      echo "Enabling and starting sshd..."
      esudo ${aLib.cmds.systemctl} enable --now ssh
      echo "sshd setup complete."
    fi
  '';
}
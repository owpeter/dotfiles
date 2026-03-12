{ config, lib, pkgs, ... }:

{
  home.activation.setupSshd = lib.hm.dag.entryAfter ["installSystemPkgs"] ''
    SECRET_FILE="$HOME/.config/dotfiles/secrets.nix"
    if [ ! -f "$SECRET_FILE" ]; then
      echo "No password file found at $SECRET_FILE."
      exit 0
    fi
    SUDO_PWD=$(${pkgs.gnugrep}/bin/grep -w "home\.passwd" "$SECRET_FILE" | sed -n "s/.*home\.passwd[[:space:]]*=[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1)
    if [ -z "$SUDO_PWD" ]; then
      echo "Failed to extract password from $SECRET_FILE."
      exit 1
    fi
    HOST_SUDO="/usr/bin/sudo"
    HOST_SYSTEMCTL="/usr/bin/systemctl"
    SSHD_CONFIG="/etc/ssh/sshd_config"
    if [ -z $DRY_RUN_CMD ]; then
      echo "Configuring sshd..."
      if ! ${pkgs.gnugrep}/bin/grep -q "^PasswordAuthentication no" "$SSHD_CONFIG"; then
        echo "$SUDO_PWD" | $HOST_SUDO -S ${pkgs.gnused}/bin/sed -i \
          's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"
      fi
      if ! ${pkgs.gnugrep}/bin/grep -q "^PubkeyAuthentication yes" "$SSHD_CONFIG"; then
        echo "$SUDO_PWD" | $HOST_SUDO -S ${pkgs.gnused}/bin/sed -i \
          's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "$SSHD_CONFIG"
      fi
      echo "Enabling and starting sshd..."
      echo "$SUDO_PWD" | $HOST_SUDO -S $HOST_SYSTEMCTL enable --now ssh
      echo "sshd setup complete."
    fi
  '';
}
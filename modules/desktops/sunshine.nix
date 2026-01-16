{ pkgs, config, lib, ... }:

let
  userName = config.home.username;
  sunshineAutostartDesktop = pkgs.runCommand "sunshine-autostart-desktop" {} ''
    mkdir -p $out/share/applications
    cp ${../../files/remote/sunshine.desktop} $out/share/applications/sunshine.desktop
  '';
in
{
  home.packages = with pkgs; [
    sunshine
  ];
  systemd.user.services.sunshine = {
    Unit = {
      Description = "Sunshine Game Stream Host";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.sunshine}/bin/sunshine";
      Environment = [
        "DISPLAY=:0"
        "XAUTHORITY=%h/.Xauthority"
      ];
      
      Restart = "always";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.sunshinestatus; }
    ];
  };

  xdg.autostart.entries = [
    sunshineAutostartDesktop
  ];
}
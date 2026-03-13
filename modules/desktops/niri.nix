# {...}:{}
{ config, pkgs, lib, secrets, sys, ... }:

let
  wallpaperPath = ../../resources/images/background.jpg;
  niriDesktop = [
    {
      format = "plain";
      data = "# Managed by home-manager\n";
    }
    {
      format = "ini";
      data = {
        "Desktop Entry" = {
          Name = "niri";
          Comment = "A scrollable-tiling Wayland compositor";
          Exec = "sh -c 'dbus-run-session nixGL ${pkgs.niri}/bin/niri > /tmp/niri.log 2>&1'";
          Type = "Application";
          DesktopNames = "niri";
        };
      };
    }
  ];
in
{
  home.packages = with pkgs; [
    niri
    noctalia-shell
    fuzzel
    alacritty
    swaybg
    xwayland-satellite
    wl-clipboard
    dex
  ];

  xdg.configFile."niri/config.kdl".text = ''

    spawn-at-startup "noctalia-shell"
    spawn-at-startup "xwayland-satellite"
    spawn-at-startup "swaybg" "-m" "fill" "-i" "${wallpaperPath}"
    spawn-at-startup "dbus-update-activation-environment" "--all"
    spawn-at-startup "gnome-keyring-daemon" "--start" "--components=secrets"
    spawn-at-startup "fcitx5" "-d"
    spawn-at-startup "dex" "-a" "-s" "~/.config/autostart:/etc/xdg/autostart"

    workspace "scratch" {}

    input {
      mod-key "Alt"
      mod-key-nested "Super"
      keyboard {
        xkb {
          layout "us"
        }
      }
      touchpad {
        tap
        natural-scroll
      }
    }

    layout {
      gaps 12
      center-focused-column "never"
      default-column-width { proportion 0.5; }

    }

    animations {
    }

    window-rule {
      match title="^noctalia-.*"
      open-floating true
      geometry-corner-radius 24
      focus-ring {
        off
      }
    }

    window-rule {
      match app-id="com.github.hluk.copyq"
      open-floating true
      clip-to-geometry true
    }

    window-rule {
      match app-id="qterm"
      open-floating true
      opacity 0.8
      default-floating-position x=0 y=0
      default-column-width { proportion 1.0; }
      default-window-height { proportion 1.0; }
      geometry-corner-radius 0 0 12 12
      clip-to-geometry true
    }

    binds {
      "F12" { spawn "niri-scratchpad" "-id" "qterm" "-s" "alacritty --class qterm" "-m"; }
      "Mod+Return" { spawn "alacritty"; }
      "Super+Space" { spawn "fuzzel"; }
      "Mod+Q" { close-window; }
      "Mod+Shift+E" { quit; }
      "Mod+V" { spawn "copyq" "toggle" ; }

      "Mod+Left"  { focus-column-left; }
      "Mod+Right" { focus-column-right; }
      "Mod+H"     { focus-column-left; }
      "Mod+L"     { focus-column-right; }
      
      "Mod+Shift+Left"  { move-column-left; }
      "Mod+Shift+Right" { move-column-right; }
      "Mod+Shift+H"  { move-column-left; }

      "Mod+Shift+L" { move-column-right; }
      "Mod+Plus"  { set-column-width "+10%"; }
      "Mod+Minus" { set-column-width "-10%"; }
      "Mod+F"     { maximize-column; }
      "Mod+Shift+F" { fullscreen-window; }

      "Mod+1" { focus-workspace 1; }
      "Mod+2" { focus-workspace 2; }
      "Mod+3" { focus-workspace 3; }
      "Mod+Shift+1" { move-column-to-workspace 1; }
      "Mod+Shift+2" { move-column-to-workspace 2; }
    }

    output "DP-3" {
      focus-at-startup
      scale 1.5
    }
  '';
  gtk = {
    enable = true;
    theme = {
      name = "Yaru-Dark";
      package = pkgs.yaru-theme;
    };
    iconTheme = {
      name = "Yaru";
      package = pkgs.yaru-theme;
    };
  };

  home.activation.niriStartUp = sys.config.activation {
    name = "niri.desktop";
    format = "concat";
    data = niriDesktop;
    target = "/usr/share/wayland-sessions/niri.desktop";
    mode = "0644";
    post = ''
      esudo ${sys.cmds.systemctl} restart nix-daemon
    '';
  };
}

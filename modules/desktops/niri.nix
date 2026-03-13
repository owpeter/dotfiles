# {...}:{}
{ config, pkgs, lib, secrets, sys, ... }:

let
  wallpaperPath = ../../resources/images/background.jpg;
  niri-wrapper = pkgs.writeShellScriptBin "start-niri-desktop" ''
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=niri
    export XDG_SESSION_DESKTOP=niri
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM="wayland;xcb"
    [ -f /etc/profile ] && . /etc/profile
    [ -f "$HOME/.profile" ] && . "$HOME/.profile"
    [ -f "$HOME/.bash_profile" ] && . "$HOME/.bash_profile"
    if [ -f "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" ]; then
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    fi
    ${pkgs.systemd}/bin/systemctl --user import-environment PATH XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP MOZ_ENABLE_WAYLAND
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
    exec ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${pkgs.niri}/bin/niri > "$HOME/niri.log" 2>&1
  '';
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
          Exec = "${niri-wrapper}/bin/start-niri-desktop";
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

    spawn-at-startup "${pkgs.noctalia-shell}/bin/noctalia-shell"
    spawn-at-startup "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
    spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-m" "fill" "-i" "${wallpaperPath}"
    spawn-at-startup "/usr/bin/dbus-update-activation-environment" "--all"
    spawn-at-startup "/usr/bin/gnome-keyring-daemon" "--start" "--components=secrets"
    spawn-at-startup "${config.home.profileDirectory}/bin/fcitx5" "-d"
    spawn-at-startup "${pkgs.dex}/bin/dex" "-a" "-s" "~/.config/autostart:/etc/xdg/autostart"

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
      match app-id="^quake-.*"
      open-floating true
      geometry-corner-radius 24
      focus-ring {
        off
      }
      open-focused true
    }

    window-rule {
      match app-id="com.github.hluk.copyq"
      open-floating true
      clip-to-geometry true
    }

    window-rule {
      match app-id="quake-term"
      open-floating true
      opacity 0.8
      focus-ring {
        off
      }
      default-floating-position x=0 y=0
      default-column-width { proportion 1.0; }
      default-window-height { proportion 1.0; }
      geometry-corner-radius 0 0 12 12
      clip-to-geometry true
    }

    binds {
      "F1" { spawn "${config.home.profileDirectory}/bin/screenshot"; }
      "F12" { spawn "${config.home.profileDirectory}/bin/niri-scratchpad" "-id" "quake-term" "-s" "${pkgs.alacritty}/bin/alacritty --class quake-term" "-m"; }
      "Mod+Return" { spawn "${pkgs.alacritty}/bin/alacritty"; }
      "Super+Space" { spawn "${pkgs.fuzzel}/bin/fuzzel"; }
      "Mod+Q" { close-window; }
      "Mod+Shift+E" { quit; }
      "Mod+V" { spawn "${pkgs.copyq}/bin/copyq" "toggle" ; }

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

      "Mod+Comma" { consume-or-expel-window-left; }
      
      "Mod+Period" { consume-or-expel-window-right; }
      "Mod+Up"   { focus-window-up; }
      "Mod+Down" { focus-window-down; }
      "Mod+J"   { focus-window-up; }
      "Mod+K" { focus-window-down; }
      "Mod+Shift+Up"   { move-window-up; }
      "Mod+Shift+Down" { move-window-down; }
      "Mod+W" { toggle-column-tabbed-display; }
    }

    output "DP-3" {
      focus-at-startup
      scale 1.5
    }

    output "HDMI-A-1" {
      mode custom=true "3200x2080@60"
      scale 1.75
      focus-at-startup
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

  xdg.configFile."xdg-desktop-portal/niri-portals.conf".source =  
  "${pkgs.niri}/share/xdg-desktop-portal/niri-portals.conf";

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

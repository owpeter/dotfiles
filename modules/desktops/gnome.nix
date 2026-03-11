{ pkgs, config, ... }:

let
  wallpaperPath = ../../resources/images/background.jpg;
in
{
  home.packages = with pkgs; [
    wmctrl
    xdotool
  ];

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaperPath}";
      picture-uri-dark = "file://${wallpaperPath}";
      picture-options = "zoom";
    };

    "org/gnome/shell/keybindings/toggle-message-tray" = ["<Alt>v"];
    "org/gnome/shell/extensions" = {
      "dash-to-dock" = {
        "dock-fixed" = false;
      };
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-tilix-quake/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-tilix-normal/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/google-chrome/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/btop/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-tilix-quake" = {
      name = "Tilix Quake";
      command = "tilix --quake";
      binding = "F12";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-tilix-normal" = {
      name = "Tilix";
      command = "tilix";
      binding = "<Control><Alt>t";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/google-chrome" = {
      name = "Chrome";
      command = "google-chrome-stable";
      binding = "F11";
    };
    
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/btop" = {
      name = "Btop";
      command = "quake 'class:QuakeBtop' 'tilix --new-process --class=QuakeBtop --name=QuakeBtop --geometry=120x35 -e btop'";
      binding = "<Control><Alt>Backspace";
    };
  };
}
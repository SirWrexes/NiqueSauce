{ pkgs, lib, ... }:

let
  inherit (builtins) concatLists genList;
  inherit (lib.meta) getExe getExe';

  # Moving focus/windows across workspaces
  workspaces =
    [
      "$mod,        0, workspace      , 10"
      "SUPER_SHIFT, 0, movetoworkspace, 10"

      "CONTROLALT, Delete, exec, btop"
    ]
    ++ concatLists (
      genList (
        i:
        let
          ws = i + 1;
        in
        [
          "$mod,        ${toString ws}, workspace      , ${toString ws}"
          "SUPER_SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
        ]
      ) 8
    );
in
workspaces
++ (with pkgs; [
  # Terminate the current session
  "SUPER_R, Q, exec, ${getExe uwsm} stop"

  # Lock session
  "$mod SHIFT, L, exec, ${getExe hyprlock}"

  # Open terminal
  "$mod, RETURN, exec, ${getExe kitty}"

  # Open app launcher
  "$mod, SPACE, exec, ${getExe' tofi "tofi-drun"} --drun-launch=true"

  # Open task manager
  "CTRL ALT, DELETE, exec, ${getExe btop}"

  # Open set default browser
  ", XF86HomePage, exec, ${getExe firefox}"

  # Open Discord
  ", XF86Mail, exec, ${getExe vesktop}"

  # Toggle fullscreen
  "$mod, F, fullscreen, 0"
  # Toggle pseudo-fullscreen
  "$mod SHIFT, F, fullscreen, 1"

  # Move focus with hjkl
  "$mod, H, movefocus, l"
  "$mod, J, movefocus, d"
  "$mod, K, movefocus, u"
  "$mod, L, movefocus, r"

  # Move active window with hjkl
  "$mod SHIFT, H, movewindow, l"
  "$mod SHIFT, J, movewindow, d"
  "$mod SHIFT, K, movewindow, u"
  "$mod SHIFT, L, movewindow, r"

  # Close the currently focused window
  # Note that despite the name, this uses graceful quitting, and doesn't actually kill the process.
  "$mod, ESCAPE, killactive"

  # Control volume with fn keys
  "$mod, XF86AudioMute,        exec, ${getExe pavucontrol}"
  ",     XF86AudioMute,        exec, ${getExe' wireplumber "wpctl"} set-mute toggle"
  ",     XF86AudioRaiseVolume, exec, ${getExe' wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
  ",     XF86AudioLowerVolume, exec, ${getExe' wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
  "CTRL, XF86AudioRaiseVolume, exec, ${getExe' wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 1%+"
  "CTRL, XF86AudioLowerVolume, exec, ${getExe' wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 1%-"
])

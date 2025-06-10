let
  # Moving focus/windows across workspaces
  workspaces =
    [
      "$mod,        0, workspace      , 10"
      "SUPER_SHIFT, 0, movetoworkspace, 10"
    ]
    ++ builtins.concatLists (
      builtins.genList (
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
++ [
  # Terminate the current session
  "$mod, Q, exit" # TODO use uwsm

  # Lock session
  "$mod, L, exec, hyprlock"

  # Open terminal
  "$mod, RETURN, exec, kitty"

  # Open set default browser
  ", XF86HomePage, exec, firefox"

  # Open Discord
  ", XF86Mail, exec, vesktop"

  # Move focus with hjkl
  "$mod, H, movefocus, l"
  "$mod, J, movefocus, d"
  "$mod, K, movefocus, u"
  "$mod, L, movefocus, r"

  # Move active window with hjkl
  "SUPER_SHIFT, H, movewindow, l"
  "SUPER_SHIFT, J, movewindow, d"
  "SUPER_SHIFT, K, movewindow, u"
  "SUPER_SHIFT, L, movewindow, r"

  # Close the currently focused window
  # Note that despite the name, this uses graceful quitting, and doesn't actually kill the process.
  "$mod, ESCAPE, killactive"

  # Control volume with fn keys
  ",     XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
  ",     XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
  "CTRL, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"
  "CTRL, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"
]

export XDG_SESSION_DESKTOP=XFCE
export XDG_SESSION_CLASS="user" 
export XDG_SESSION_TYPE="x11"
xset b off
xrandr --output HDMI1 --auto --primary --output eDP1 --auto --right-of HDMI1
/usr/lib/xfce-polkit/xfce-polkit &
(while true; do /usr/lib/xfce4/notifyd/xfce4-notifyd; sleep 1; done) &
/usr/lib/bamf/bamfdaemon &
thunar --daemon &
xfwm4 --replace &
dapper -e ~/.config/dapper/autostart &
xfdesktop

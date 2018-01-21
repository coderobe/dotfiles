export XDG_SESSION_DESKTOP=XFCE
export XDG_SESSION_CLASS="user" 
export XDG_SESSION_TYPE="x11"
xset b off
xrandr --output HDMI-1 --auto --primary --output eDP-1 --auto --right-of HDMI-1
xss-lock -- i3lock-fancy &
/usr/lib/xfce-polkit/xfce-polkit &
#(while true; do /usr/lib/xfce4/notifyd/xfce4-notifyd; sleep 1; done) &
dunst &
/usr/lib/bamf/bamfdaemon &
thunar --daemon &
xfwm4 --replace &
dapper -e ~/.config/dapper/autostart &
exec xfdesktop

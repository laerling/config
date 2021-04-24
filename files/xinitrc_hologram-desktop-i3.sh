# Screen config belongs in holodecks, since it's machine-dependent
[[ -f /etc/X11/xinit/Xresources ]] && xrdb -merge /etc/X11/xinit/Xresources # load global Xresources provided by this hologram
guake -e 'screen -DR' &
exec i3

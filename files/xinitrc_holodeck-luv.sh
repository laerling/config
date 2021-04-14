xrandr --auto --output VGA-1 --primary --left-of LVDS-1 # external screen (e. g. a projector), if available, over regular screen
externalscreen=$(xrandr | grep 'VGA-1 connected')

# show wallpaper on external screen only
if [ -n "$externalscreen" ]; then
	feh --bg-fill --xinerama-index 0 /home/laerling/.wallpaper
fi

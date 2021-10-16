xrandr --auto --output VGA-1 --primary --left-of LVDS-1 # external screen (e. g. a projector), if available, over regular screen

wallpaper_path=/home/laerling/.wallpaper

wp="$(realpath "$wallpaper_path")"
if [ -e "$wp" ]; then
  wallpaper_on_external_screen_only=''
  if [ -n "$wallpaper_on_external_screen_only" ]; then
    externalscreen=$(xrandr | grep 'VGA-1 connected')
    if [ -n "$externalscreen" ]; then
      feh --bg-fill --xinerama-index 0 "$wallpapaer_path"
    fi
  else
    feh --bg-fill "$wp"
  fi
fi

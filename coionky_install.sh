killall conky 2>/dev/null
sleep 1

# if there is no hidden folder autostart then make one
[ -d $HOME"/.config/autostart" ] || mkdir -p $HOME"/.config/autostart"

# if there is no hidden folder conky then make one
[ -d $HOME"/.config/conky" ] || mkdir -p $HOME"/.config/conky"

echo "The files have been copied to ~/.config/conky."
# the standard place conky looks for a config file
cp -r * ~/.config/conky/

echo "Making sure conky autostarts next boot."
# making sure conky is started at boot
cp conky.desktop ~/.config/autostart/conky.desktop

if ! location="$(type -p "sensors")" || [ -z "sensors" ]; then
	echo "installing lm-sensors for this script to work"
  	sudo apt-get install lm-sensors
  else
  	echo "lm-sensors is already installed. Proceeding..."

fi
conky -q ~/.config/conky/conky.conf &
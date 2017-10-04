killall conky 2>/dev/null
sleep 1

# if there is no hidden folder autostart then make one
[ -d $HOME"/.config/autostart" ] || mkdir -p $HOME"/.config/autostart"

# if there is no hidden folder conky then make one
[ -d $HOME"/.config/conky" ] || mkdir -p $HOME"/.config/conky"

echo "The files have been copied to ~/.config/conky."
# the standard place conky looks for a config file
cp -r * ~/.config/conky/

cp .conkyrc ~/.conkyrc

echo "Making sure conky autostarts next boot."
# making sure conky is started at boot
cp conky.desktop ~/.config/autostart/conky.desktop

if ! location="$(type -p "conkey")" || [ -z "conkey" ]; then
  echo "installing conkey with lua for this script to work"
    sudo apt-get install conky-all
  else
    echo "conkey with lua is already installed. Proceeding..."

fi
if ! location="$(type -p "sensors")" || [ -z "sensors" ]; then
  echo "installing lm-sensors for this script to work"
    sudo apt-get install lm-sensors
  else
    echo "lm-sensors is already installed. Proceeding..."

fi
if ! location="$(type -p "jq")" || [ -z "jq" ]; then
	echo "installing jq this script to work"
  	sudo apt-get install jq
  else
  	echo "jq is already installed. Proceeding..."

fi
if ! location="$(type -p "curl")" || [ -z "curl" ]; then
	echo "installing curl this script to work"
  	sudo apt-get install curl
  else
  	echo "curl is already installed. Proceeding..."

fi
echo "running conky.."
conky -q ~/.config/conky/conky.conf &
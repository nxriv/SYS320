#!/bin/bash

# Storyline: Menu for admin, VPN, and Security functions

function invalid_opt() {

	echo ""
	echo "Invalid option"
	echo ""
	sleep 2

}

function menu() {

	# clears the screen
	clear

	echo "[1] Admin Menu"
	echo "[2] Security Menu"
	echo "[3] Exit"
	read -p "Please enter a choice above: " choice

	case "$choice" in

	1) admin_menu
	;;

	2) security_menu
	;;

	3) exit 0
	;;

	*)

		invalid_opt
		# Call the main menu
		menu
	;;
	esac



}

function admin_menu() {


	echo "[L]ist Running Processes"
	echo "[N]etwork Sockets"
	echo "[V]PN Menu"
	echo "[4] Exit"
	read -p "Please enter a choice above: " choice

	case "$choice" in

		L|l) ps -ef |less
		;;
		N|n) netstat -an --inet |less
		;;
		V|v) vpn_menu
		;;
		4) exit 0
		;;

		*)
			invalid_opt

			admin_menu
		;;
	esac


admin_menu
} 

function vpn_menu() {

	echo "[A]dd a peer"
	echo "[D]elete a peer"
	echo "[B]ack to admin menu"
	echo "[M]ain menu"
	echo "[E]xit"
	read -p "Please select an option: " choice

	case "$choice" in

	A|a) 
		bash peer.bash
		tail -6 wg0.conf |less
	;;
	D|d)
	# Create a prompt for the user
	# Call the manage-user.bash and pass the proper switches and argument
	# To delete the user.

	;;
	B|b) admin_menu
	;;
	M|m) menu
	;;
	E|e) exit 0
	;;
	*)
		invalid_opt

	;;

	esac

vpn_menu
}

function security_menu() {

	echo "[1] List open network sockets"
	echo "[2] Check if any non root users have UID 0"
	echo "[3] Check last 10 logged in users"
	echo "[4] See logged in users"
	echo "[5] Block List Menu"
	echo "[E]xit"

	read -p "Please select an option: " choice

	case  "$choice" in

	1) ss -tulpn |less
	;;
	2) awk -F: '($3 == 0) && ($1 != "root") {print}' /etc/passwd |less
	;;
	3) last -a | head -n 10 |less
	;;
	4) who |less
	;;
	5) bl_menu
	;;
	E|e) exit 0
	;;
	*)
		invalid_opt
	;;

	esac

security_menu
}

function bl_menu() {
	# Check if bad IPs file does not exist.
	if [[ ! -f badips.txt  ]]
	then
		echo "The badIPs.txt file does not exist yet. Downloading file..."
		sleep 1
		wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -O /tmp/emerging-drop.suricata.rules
		egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' /tmp/emerging-drop.suricata.rules | sort -u | tee badips.txt	
	fi

	echo "[C]isco blocklist generator"
	echo "[D]omain URL blocklist generator"
	echo "[W]indows blocklist generator"
	echo "[E]xit"

	read -p "Please select an option: " choice

	case  "$choice" in
	# Parse badips file to prepare for badips.cisco file generation using regex.
	C|c)
	    egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badips.txt | tee badips.nocidr
	  	for eachip in $(cat badips.nocidr)
  	do
  		echo "deny ip host ${eachip} any" | tee -a badips.cisco
	  done
	  rm badips.nocidr
clear
  echo 'Created IP Tables for firewall drop rules in file "badips.cisco"'
  sleep 2
	;;
	D|d)
	# Pull file for domain generation.
	  wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
	  awk '/domain/ {print}' /tmp/targetedthreats.csv | awk -F \" '{print $4}' | sort -u > threats.txt
	  echo 'class-map match-any BAD_URLS' | tee ciscothreats.txt
	    for eachip in $(cat threats.txt)
	   do
		    echo "match protocol http host \"${eachip}\"" | tee -a ciscothreats.txt
	  done
	  rm threats.txt
	  echo 'Cisco URL filters file successfully parsed and created at "ciscothreats.txt"'
	  sleep 2
	;;
	W|w)
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badips.txt | tee badips.windowsform
	  for eachip in $(cat badips.windowsform)
	do
		echo "netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS - ${eachip}\" dir=in action=block remoteip=${eachip}" | tee -a badips.netsh
	done
	  rm badips.windowsform
	  clear
	  echo "Created IPTables for firewall drop rules in file \"badips.netsh\""
	  sleep 2
	;;
	E|e) exit 0
	;;
	*)
		invalid_opt
	;;

	esac

bl_menu
}

# Call the main function
menu

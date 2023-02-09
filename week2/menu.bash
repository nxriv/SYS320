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
	E|e) exit 0
	;;
	*)
		invalid_opt
	;;

	esac

security_menu
}

# Call the main function
menu

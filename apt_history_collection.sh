#!/usr/bin/env bash

DATE="$(date +'%d-%m-%y_%H:%M')"
LINE_COUNT="$2"
ARG1="$1"
ARG3="$3"
UPDATE_LOG="/var/log/apt/history.log"
COLLECTED_log="COLLECTED.aptlog"
APT_CONF_PATH="/etc/apt/apt.conf.d"
case "$1" in
	"--last")
		if [[ -z $LINE_COUNT ]];
		then
			printf "no amount of line count was provide, so only collecting tail section of log.\n"
			cat $UPDATE_LOG | tail &> $COLLECTED_log
		else
			if [[ -z $ARG3 ]];
			then
				cat $UPDATE_LOG | tail -$LINE_COUNT &> $COLLECTED_log
			else
				cat $UPDATE_LOG | tail -$LINE_COUNT | grep -i $ARG3 &> $COLLECTED_log
			fi
		fi


	;;
	"--conf")
		case "$2" in
			"list")
				echo "conf list path: $APT_CONF_PATH"
				ls -ltr $APT_CONF_PATH
			;;
			"info")
				if [[ -z $3 ]];
				then
					echo "provide conf name"
				else
					cat $APT_CONF_PATH/$ARG3
				fi
			;;
		*)
			printf "available options: [ list ]\n"
		esac
	;;
*)
	printf "available options:
--last\t\t\t\t:collects tail section of apt-updated logs
--last 100\t\t\t:collects last 100 line of apt-updates logs
--last 100 ubuntu\t\t:collects last 100 line of ubuntu related apt-updates logs
--conf list\t\t\t:shows the apt configuration list
--conf info <config name>\t:shows the value of conf file\n"
esac

#! /bin/sh -e

case "$1" in
	start )
		mkdir -p /etc/dropbear
		if [ ! -f /etc/dropbear/dropbear_rsa_host_key ] ; then
			echo "generating RSA key..."
			dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key >/dev/null 2>&1
		fi
		dropbear
		;;
	stop )
		killall dropbear
		;;
	restart )
		$0 stop
		$0 start
		;;
	* )
		echo "usage: $0 (start|stop|restart)"
		exit 1
esac

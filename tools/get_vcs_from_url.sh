#! /bin/sh -e

# try to guess the VCS to use for the URL

URL=$*

PROTOCOL=$(echo $URL | cut -d':' -f1 | cut -d'+' -f1)
if [ "$PROTOCOL" = "http" -o "$PROTOCOL" = "https" ] ; then
	if echo $URL | fgrep -qi git ; then
		echo git
	elif echo $URL | fgrep -qi hg ; then
		echo hg
	elif echo $URL | fgrep -qi svn ; then
		echo svn
	elif echo $URL | fgrep -qi cvs ; then
		echo cvs
	else
		echo $PROTOCOL
	fi
else
	echo $PROTOCOL
fi

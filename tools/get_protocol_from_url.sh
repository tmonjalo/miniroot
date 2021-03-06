#! /bin/sh -e

# try to guess the protocol to use for the URL

URL=$*

# get the URL prefix
PROTOCOL=$(echo $URL | cut -d':' -f1 | cut -d'+' -f1)
if echo $PROTOCOL | grep -q '^\(http\|ssh\)' ; then
	# search a magic string inside the URL
	if echo $URL | fgrep -qi git ; then
		echo git
	elif echo $URL | fgrep -qi hg ; then
		echo hg
	elif echo $URL | fgrep -qi svn ; then
		echo svn
	elif echo $URL | fgrep -qi cvs ; then
		echo cvs
	else
		# HTTP or failed
		echo $PROTOCOL
	fi
else
	# protocol defined by prefix
	echo $PROTOCOL
fi

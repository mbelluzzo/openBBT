#!/bin/bash

#set -x
set  -e

GST="gst-launch-1.0"
MYSELF=${0##*/}

function help()
{
cat <<EOF

Usage: $MYSELF [-h] [--help] [-v] [--version]
Description:
   -h, --help              Help page
   -p, --inspect-plugins   Check installed plugins for basic tasks
   -s, --check-srcsink     Verify video/audio sources
   -e, --img-encoding      Dump a frame to a file using
                           an image format (JPEG and PNG)
   -v, --version           Show version
EOF
}
function inspect_gst_plugins()
{
	plugins=(
		"theora"
		"opencv"
		"udp"
		"tcp"
		"audioconvert"
		"videoconvert"
		"video4linux2"
		"rtp"
		"debug"
		"vorbis"
		"png"
		"typefindfunctions"
		"opengl"
		"ogg"
		"jpeg"
		"videofilter"
		"audiomixer"
		"geometrictransform"
		"playback"
		"matroska")

	for plugin in ${plugins[*]}; do
		gst-inspect-1.0 $plugin
	done

	exit 0
}

function check_va_sources()
{
	gst_sources=("videotestsrc"
		     "audiotestsrc")

	for src in ${gst_sources[*]}; do
		$GST $src num-buffers=1 ! fakesink silent=0
	done

	exit 0;
}

function img_encoding_dump()
{
	declare -A img_codecs

	img_codecs[jpeg]="JPEG"
	img_codecs[png]="PNG"

	for codec in ${!img_codecs[*]}; do
		echo "$codec  ${img_codecs[$codec]}"
		$GST videotestsrc num-buffers=1 ! \
				"${codec}enc"  ! \
				filesink location=test.${codec}
		format=$(file test.${codec} | grep -wo ${img_codecs[$codec]})
		if [ -z "$format" ]; then
			echo "bad encoding" 1>&2
			exit 1
		fi
	done

	exit 0
}

while (( $# ))
do
	case $1 in
	-h|--help)
		help
	;;
	-p|--inspect-plugins)
		inspect_gst_plugins
	;;
	-s|--check-srcsink)
		check_va_sources
	;;
	-e|--img-encoding)
		img_encoding_dump
	;;
	-v|--version)
		echo "$MYSELF version 0.1"
	esac
	shift
done

exit 0

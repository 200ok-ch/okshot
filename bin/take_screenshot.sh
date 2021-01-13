#!/bin/bash

set -e

short_uuid=`uuidgen -r | sed 's/-/\n/g' | head -n 1`
timestamp=`date +"%Y_%m_%d"-$short_uuid`
screenshot=screenshot_$timestamp.png

if [[ $1 == -c ]]; then
  xclip -selection clipboard -t image/png -o > /tmp/$screenshot
elif [[ $1 == -h ]]; then
  echo "Usage: take_screenshot.sh COMMAND\n"
  echo "COMMAND must be one of:\n"
  echo " -c: Copy clipboard to file and upload"
  echo " -i: Use inkscape to edit the screenshot and upload"
  echo " -h: Show this help"
elif [[ $1 == -i ]]; then
  import /tmp/$screenshot

  # Do a little dance for inkscape. It does not like saving PNG files
  # (only exporting them). Hence the png gets converted to SVG
  # temporarily.
  inkscape -o /tmp/$screenshot.svg /tmp/$screenshot

  # INFO: This works in that Inkscape is in full screen, but the
  # remaining script runs through without waiting for inkscape to
  # quit.

  # i3-msg exec "inkscape /tmp/$screenshot.svg"
  # i3-msg -t subscribe -m '[ "window" ]' | read
  # i3-msg fullscreen enable

  # This is an alternative solution using the generic `wmctrl` instead
  # of i3 interna.

  inkscape /tmp/$screenshot.svg &
  pid="$!"

  # Wait for the window to open and grab its window ID
  winid=''
  while : ; do
    winid="`wmctrl -lp | awk -vpid=$pid '$3==pid {print $1; exit}'`"
    [[ -z "${winid}" ]] || break
  done

  # Focus the window
  wmctrl -ia "${winid}"

  # Make it fullscreen
  wmctrl -ia "${winid}" -b toggle,fullscreen

  # Wait for the application to quit
  wait "${pid}";

  inkscape -o /tmp/$screenshot /tmp/$screenshot.svg

  rm /tmp/$screenshot.svg
elif [[ $1 == -s ]]; then
  import /tmp/$screenshot
else
  exit 1
fi

echo "SCREENSHOT FILE: "

echo "/tmp/${screenshot}"


if [[ $2 == -C ]]; then
  # Copy to clipboard
  xclip -selection clipboard -t image/png -i /tmp/$screenshot

  notify-send "Copied screenshot to clipboard"
else
  # Upload to host
  HOST=$OKSHOT_HOST
  USER=$OKSHOT_USER
  PASSWD=$OKSHOT_PASSWORD

  ftp -p -n -v $HOST <<END_SCRIPT
user $USER $PASSWD
put /tmp/$screenshot $screenshot
quit
END_SCRIPT

  screenshot_url="$OKSHOT_URL_PREFIX/$screenshot"
  echo $screenshot_url | xclip -selection c
  notify-send "Copied $screenshot_url to clipboard"
fi

exit 0

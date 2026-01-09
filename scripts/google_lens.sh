#!/usr/bin/env bash
# Upload image to uguu.se and open in Google Lens
# Expects image at /tmp/image.png (captured by ScreenshotTool)

if [[ ! -f /tmp/image.png ]]; then
	notify-send "Google Lens" "No image found at /tmp/image.png"
	exit 1
fi

imageLink=$(curl -sF files[]=@/tmp/image.png 'https://uguu.se/upload' | jq -r '.files[0].url')
xdg-open "https://lens.google.com/uploadbyurl?url=${imageLink}"
rm /tmp/image.png

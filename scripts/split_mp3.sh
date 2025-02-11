#!/bin/bash
echo "Disable Powersave"
ffmpeg -i source.MP3 -f segment -segment_time 120 %03d.mp3

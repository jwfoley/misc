#! /bin/bash

# given a list of video files, convert each one to a probably smaller format (H.265 + Opus in MKV)
# issue: if the video contains multiple audio tracks (or video for some reason?), you'll get all of them - this is probably not desired since we're downmixing to stereo anyway

video_options='-vcodec libx265 -crf 23'
audio_options='-acodec libopus -b:a 64k -ac 2' # '-ac 2' reduces to stereo, if not already
other_options='-scodec copy -map 0' # 'map 0' requires all input streams to be mapped in output (so e.g. you don't lose some subtitle tracks)
file_extension='.mkv' # determines container

if [ ! -n "$1" ]
then
	echo "usage: $(basename $0) file1.mp4 file2.avi ..."
	exit 1
fi

set -euo pipefail

for in_file in "$@"
do
	ffmpeg -i $in_file $video_options $audio_options $other_options $(basename $in_file | sed "s/\..*/$file_extension/")
done


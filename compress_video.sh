#! /bin/bash

# given a list of video files, convert each one to a probably smaller format (H.265 + Opus in MKV)
# per ffmpeg behavior it chooses only the video stream with the highest resolution, the audio stream with the most channels (but downmixed to stereo), and the first subtitle stream

video_options='-vcodec libx265 -crf 23'
audio_options='-acodec libopus -b:a 64k -ac 2' # '-ac 2' reduces to stereo, if not already
other_options='-scodec copy' #
file_extension='.recompress.mkv' # determines container

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


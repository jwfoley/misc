#! /bin/bash

# given directories containing media files, transcode them as Opus audio and save them directly to an MTP device
# assumes MTP device is mounted via GVFS by the current user (standard in Ubuntu)
# also copies album art if present

ffmpeg_args='-vn -b:a 64k -ac 2' # no video, 64 kbps, force stereo
devicepath=/run/user/$UID/gvfs/mtp*
outpath='Internal storage/Music'
filetypes=(mp3 flac m4a mp4)
artfiles=(Folder.jpg AlbumArt*.jpg)

if [ ! -n "$1" ]
then
	echo "usage: $(basename $0) directory1 directory2 ..."
	exit 1
fi

if [ $(ls -d $devicepath | wc -l) -eq 0 ]
then
	echo 'error: no MTP device found'
	exit 1
elif [ $(ls -d $devicepath | wc -l) -gt 1 ]
then
	echo 'error: multiple MTP devices connected'
	exit 1
fi
devicepath=$(echo $devicepath)

wd=$(pwd)

set -euo pipefail

for dir in "$@"
do
	dirname=$(basename "$dir")
	if [ ! -d "$devicepath/$outpath/$dirname" ]
	then
		mkdir "$devicepath/$outpath/$dirname"
	fi
	
	for filetype in ${filetypes[@]}
	do
		if [ $(compgen -G "$dir/*.$filetype" | wc -l) -gt 0 ]
		then
			for sourcefile in "$dir"/*.$filetype
			do
				newfile=$(basename "$sourcefile" | sed "s/\.$filetype$/.opus/")
				ffmpeg -i "$sourcefile" "$ffmpeg_args" "$devicepath/$outpath/$dirname/$newfile"
			done
		fi
	done
	
	for arttype in ${artfiles[@]}
	do
		if [ $(compgen -G "$dir/$arttype" | wc -l) -gt 0 ]
		then
			cp "$dir"/$arttype "$devicepath/$outpath/$dirname/"
		fi
	done
	
done


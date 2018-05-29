#! /bin/bash

# given a list of JPEG images, automatically generate recompressed JPEGs with jpeg-recompress (from jpeg-archive)
# output goes in the working directory

recompress_command='jpeg-recompress -q veryhigh -a -m mpe'
parallel_command=parallel
new_suffix='.recompress.jpg'


if [ ! -n "$1" ]
then
	echo "usage: $(basename $0) file1.jpg file2.jpg file3.jpg ..." >&2
	exit 1
fi

set -euo pipefail

$parallel_command "$recompress_command {} {/.}$new_suffix" ::: "$@"


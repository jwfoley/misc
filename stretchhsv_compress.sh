#! /bin/bash

# given a list of images in any GIMP-recognized format, automatically process all of them in GIMP and then generate recompressed JPEGs with jpeg-recompress (from jpeg-archive)
# output goes in the working directory
# uses "stretchhsv.sh" for the GIMP step

gimp_command="$(dirname $0)/stretchhsv.sh"
recompress_command='jpeg-recompress -q veryhigh -a -m mpe'
parallel_command=parallel
new_suffix='.recompress.jpg' # in addition to the one added by stretchhsv.sh
n_workers=$(nproc)

if [ ! -n "$1" ]
then
	echo "usage: $(basename $0) file1.jpg file2.jpg file3.png ..." >&2
	exit 1
fi


set -euo pipefail

tmp_dir=$(mktemp -d --suffix .stretch_compress)
out_dir=$(pwd)
infiles=
for filename in "$@"
do
	infiles="$infiles $(readlink -f $filename)"
done

cd $tmp_dir
$gimp_command $infiles
cd $out_dir
$parallel_command "$recompress_command {} {/.}$new_suffix" ::: $tmp_dir/*

rm -rf $tmp_dir


#! /bin/bash

# given a list of images in any GIMP-recognized format, automatically process all of them in GIMP and then generate recompressed JPEGs with jpeg-recompress (from jpeg-archive)
# output goes in the working directory
# efficiently parallelized to create multiple GIMP workers
# current GIMP procedure is to run the Auto Stretch HSV plugin but other things are possible

gimp_command=gimp
gimp_procedure='(plug-in-autostretch-hsv RUN-NONINTERACTIVE image drawable)'
recompress_command='jpeg-recompress -q veryhigh -a -m mpe'
tmp_suffix='.jpg'
final_suffix='.stretchhsv.recompress.jpg'
n_workers=$(nproc)

if [ ! -n "$1" ]
then
	echo "usage: $(basename $0) file1.jpg file2.jpg file3.png ..." >&2
	exit 1
fi


tmp_dir=$(mktemp -d --suffix .stretch_compress)
infiles=()
tempfiles=()
counter=0
for filename in "$@"
do
	i=$(($counter % $n_workers))
	infiles[$i]="${infiles[$i]} \"$filename\""
	tempfiles[$i]="${tempfiles[$i]} \"$tmp_dir/"$(basename $filename | sed -E "s/\..+?/$tmp_suffix/")"\""
	counter=$(($counter + 1))
done

set -euo pipefail

for worker in ${!infiles[@]}
do
	echo "(
		let* (
			(infiles (list ${infiles[$worker]}))
			(outfiles (list ${tempfiles[$worker]}))
		)
		(while (not (null? infiles))
			(
				let* (
					(infile (car infiles))
					(outfile (car outfiles))
					(image (car (gimp-file-load RUN-NONINTERACTIVE infile infile)))
					(drawable (car (gimp-image-get-active-layer image)))
				)
				$gimp_procedure
				(gimp-file-save RUN-NONINTERACTIVE image drawable outfile outfile)
				(gimp-image-delete image)
			)
			(set! infiles (cdr infiles))
			(set! outfiles (cdr outfiles))
		)
		(gimp-quit 0)
	)" | $gimp_command -ib - &
done

wait $(jobs -p)

parallel "$recompress_command {} {/.}$final_suffix" ::: $tmp_dir/*$tmp_suffix

rm -rf $tmp_dir


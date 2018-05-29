#! /bin/bash

# given a list of images in any GIMP-recognized format, automatically process all of them in GIMP 
# output goes in the working directory
# efficiently parallelized to create multiple GIMP workers
# current GIMP procedure is to run the Auto Stretch HSV plugin but other things are possible

gimp_command=gimp
gimp_procedure='(plug-in-autostretch-hsv RUN-NONINTERACTIVE image drawable)'
new_suffix='.stretchhsv.jpg' # determines output file format
n_workers=$(nproc)

if [ ! -n "$1" ]
then
	echo "usage: $(basename $0) file1.jpg file2.jpg file3.png ..." >&2
	exit 1
fi

infiles=()
outfiles=()
counter=0
for filename in "$@"
do
	i=$(($counter % $n_workers))
	infiles[$i]+=" \"$filename\""
	outfiles[$i]+=" \""$(basename $filename | sed -E "s/\..+?/$new_suffix/")"\""
	((counter++))
done

set -euo pipefail

for worker in ${!infiles[@]}
do
	echo "(
		let* (
			(infiles (list ${infiles[$worker]}))
			(outfiles (list ${outfiles[$worker]}))
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


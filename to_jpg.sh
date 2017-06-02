# convert all .bmp files in working directory to .jpg

set -e
for file in *.bmp
do convert "$file" "$(echo $file | sed -e "s/\.bmp$/.jpg/")"
done
rm *.bmp


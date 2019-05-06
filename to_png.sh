# convert all .bmp files in working directory to .png

set -e
for file in *.bmp
do convert "$file" "$(echo $file | sed -e "s/\.bmp$/.png/")"
done
rm *.bmp


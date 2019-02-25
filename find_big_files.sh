# find large files below the current directory and make a list of them by compression ratio, estimated from a test run of the first megabyte, so you can identify candidates for compression to save disk space

find . -size +1G -exec du -0h {} \; -exec echo -ne "\t" \; -exec bash -c 'echo $((1048576 / $(dd if="$0" bs=1M count=1 2>/dev/null | gzip | wc -c)))' {} \; | tr -d '\000' | sort -rnk 3 -nk 1


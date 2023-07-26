# find large files below the current directory and make a list of them with date of last modification and potential compression ratio, estimated from a test run of the first megabyte, so you can identify candidates for compression or deletion to save disk space

find . -size +1G -exec du -0 {} \; -exec echo -ne "\t" \; -exec stat --printf='%y\t' {} \; -exec bash -c 'echo $((1048576 / $(dd if="$0" bs=1M count=1 iflag=noatime 2>/dev/null | zstd | wc -c)))' {} \; | tr -d '\000'


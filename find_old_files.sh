# find large files below the current directory that haven't been accessed (atime) in more than a month and make a list of them by atime

find . -size +1G -atime +30 -exec stat --printf='%x\t' {} \; -exec du -h {} \; | sort -k 1


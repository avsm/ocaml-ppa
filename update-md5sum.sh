  find $MD5SUMS_DIR -name "*$MD5SUMS_EXT" -exec cat {} \; 2> /dev/null |
  while read md5sum unit; do
    echo "$md5sum #PACKAGE# #VERSION# $unit"
  done > $MD5SUMS_INDEX

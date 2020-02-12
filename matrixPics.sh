#!/bin/bash
########################################################################################
#
# matrixPics.sh
# create image definitions suitable for ws2812b 16x16 matrix from all .png in folder
#
# this script needs imagemagick installed 
# as it is it will snip of the firstchar of the .png filename 
# u1f302.png -> 1f302.dat
# as it proceeds it builds an index from all the filenames so we can go there one by one
# char index[]={"1f302","1f303",...}
########################################################################################
#
# (C) Daniel Planets, 01/2020, Berlin
# https://github.com/planetar/matrixPics
#


indexFile="index.dat"
echo "const char* findex[] = {" > $indexFile

entry=0
for f in *.png; do 
        entry=$((entry+1))
	# trim the outname
	ona=${f%.*}
	outName="${ona:1}"
        outFile="${ona:1}".dat
	echo "Processing $f -> $outFile"
        echo "const long pic[]  ={" > $outFile
        
        # the magick
        `convert $f -resize 16x16 -background black -alpha remove -colorspace RGB -auto-level rgb:- | xxd -g3 -c48 > xyzzyxx.tmp`
        
        # now twist it in shape
        var=2
        input="./ccxx.tmp"
        while IFS= read -r line
        do
            a=( $line )
            var=$((var+1)) 
            #echo "$line"
            if (( $var % 2 )); then
                # var id odd
                echo  0x${a[16]}, 0x${a[15]}, 0x${a[14]}, 0x${a[13]}, 0x${a[12]}, 0x${a[11]}, 0x${a[10]}, 0x${a[9]}, 0x${a[8]}, 0x${a[7]}, 0x${a[6]}, 0x${a[5]}, 0x${a[4]}, 0x${a[3]}, 0x${a[2]}, 0x${a[1]}, >> $outFile
            else
                # var is even
                echo  0x${a[1]}, 0x${a[2]}, 0x${a[3]}, 0x${a[4]}, 0x${a[5]}, 0x${a[6]}, 0x${a[7]}, 0x${a[8]}, 0x${a[9]}, 0x${a[10]}, 0x${a[11]}, 0x${a[12]}, 0x${a[13]}, 0x${a[14]}, 0x${a[15]}, 0x${a[16]}, >> $outFile
            fi

        done < "$input"

echo "};" >> $outFile

# add a comma, starting with the second
if [ "$entry" -ne "1" ]; then
	echo -n ", " >> $indexFile
fi

# format the index in rows starting a new line after 18 entries
if (( !($entry % 18) )); then
	echo " " >> $indexFile
fi

echo -n "\"$outName\"" >> $indexFile
done

echo "}; " >> $indexFile

# remove the temp file
`rm xyzzyxx.tmp`

exit 0


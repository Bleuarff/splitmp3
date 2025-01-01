#!/usr/bin/bash

####################################
#
# Split mp3 files in small chunks
#
# usage: splitmp3 <duration> FILES
#####################################

# chunk length in minutes
partLen=$1

# folder for source mp3 files
filearg=$2

# find all mp3 files
sources=($(find "$filearg" -name "*.mp3"))

# echo "sources: $sources"

# for each file
for file in "${sources[@]}"
do
    # ffmpeg with only input file and no other param: get file info
    # grep to extract duration
    # cut to keep length only
    # awk to convert duration in minutes
    dur=$(ffmpeg -i "$file" 2>&1 | grep -Eo 'Duration: [0-9:]+' | cut -c 11- | awk -F: '{ print ($1 * 60) + $2}')

    # get number of chunks
    partsCount=`echo "$dur/$partLen" | bc`

    # ignore file if smaller than 2x chunk length
    if [ $partsCount -lt 2 ]
    then
        echo "$(basename "$file") is too short to split"
        continue
    fi

    # get file name and directory
    name=$(basename "$file" .mp3)
    dir=$(dirname "$file")
 
    # process file for each chunk
    for i in `seq 1 $partsCount`;
    do
        # ffmpeg start and end args
        start=`echo "($i-1)*$partLen*60" | bc`
        end="-to "+`echo "$start+$partLen*60" | bc`

        # ignore end arg for last chunk
        if [ "$i" = "$partsCount" ]
        then
            end=""
        fi

        partPath="$dir/$name-$i.mp3"

        cmd="ffmpeg -v 8 -i "$file" -vn -acodec copy -ss $start $end \"$partPath\""
        echo "$cmd"
        $(eval $cmd)

    done

done
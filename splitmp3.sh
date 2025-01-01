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
sources=($(find "$filearg" -name *.mp3))

# for each file
for file in "${sources[@]}"
do
    # ffmpeg with only input file and no other param: get file info
    # grep to extract duration
    # cut to keep length only
    # awk to convert duration in minutes
    dur=$(ffmpeg -i "$file" 2>&1 | grep -Eo 'Duration: [0-9:]+' | cut -c 11- | awk -F: '{ print ($1 * 60) + $2}')
    
    # TODO: ignore file if smaller than 2x chunk length

    # get number of chunks
    partsCount=`echo "$dur/$partLen" | bc`
    
    # get file name and directory
    name=$(basename "$file" .mp3)
    dir=$(dirname "$file")
 
    # process file for each chunk
    for i in `seq 1 $partsCount`;
    do
        # ffmpeg start and end args
        start=`echo "($i-1)*$partLen*60" | bc`
        end="-to "+`echo "$start+20*60" | bc`

        # ignore end arg for last chunk
        if [ "$i" = "$partsCount" ]
        then
            end=""
        fi

        partPath="$dir/$name-$i.mp3"
        echo ffmpeg -i "$file" -vn -acodec copy -ss $start $end "$partPath"
        ffmpeg -i "$file" -vn -acodec copy -ss $start $end "$partPath"

    done

done
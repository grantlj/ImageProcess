#!/bin/bash

set -e
set -o
set -u
set -x

if [ $# -lt 1 ]
then
        echo "Usage: $0 cluster_name(psc|pdl|rocks)"
        exit -1
fi

cluster=$1
videos=(HVC191553 HVC487722 HVC685238)
width=(640 176 400)
height=(272 120 300)
passed=(1 1 1)

for i in 0 1 2; do
	video=${videos[$i]}
	w=${width[$i]}
	h=${height[$i]}
	./$cluster/siftmotionffmpeg -r -t 1 -k 2 -z ../videos/$video.mp4 tmp/mosift_raw_$video.gz
	./$cluster/txyc kmeans/mosift_MED11_centers 4096 tmp/mosift_raw_$video.gz tmp/mosift_txyc_$video.txyc
	./$cluster/spbof tmp/mosift_txyc_$video.txyc $w $h 4096 10 tmp/mosift_spbof_$video.spbof 1
	diff tmp/mosift_spbof_$video.spbof mmdb_output/mosift_spbof_$video.spbof > tmp/spbof_diff_$video

	if [ -s tmp/spbof_diff_$video ]
	then
		echo spbof results for $video different!
		${passed[$i]} = 0
	fi
done

check=0
for i in 0 1 2; do
	if [ ${passed[$i]} == 0 ] 
	then
		echo $video check failed
		check=1
	fi
done

if [ $check == 0 ]
then
	echo check PASSED!!
fi

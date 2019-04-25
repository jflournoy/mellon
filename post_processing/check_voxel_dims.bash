#!/bin/bash

#first argument is file consisting of a list of files
filelistfile=$1
outfilename=$2
filelist=( $( cat "${filelistfile}" ) )

module load afni

echo "filename,dim,voxelsize" > "${outfilename}"

dim=( "x" "y" "z" )

for filename in "${filelist[@]}"
do
	echo "Checking ${filename}..."

	voxeldims=( $( 3dinfo "${filename}" | grep " mm" | sed -r 's/.*([0-9].[0-9]{3}) mm.*/\1/g' ) )
	dimiter=0

	echo "Found voxeldims ${voxeldims[@]}"

	for voxeldim in "${volexdims[@]}"
	do
		echo "${filename},${dim[$dimiter]},${voxeldim}" >> "${outfilename}"
		((++dimiter))
	done
done

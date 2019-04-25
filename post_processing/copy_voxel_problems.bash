#!/bin/bash


master="sub-1/ses-F09/func/sub-1_ses-F09_task-rest_acq-0005_run-0000_space-MNI152NLin2009cAsym_boldref.nii.gz"
RESET=0

for f in $( cat sids_with_voxel_problems.txt ) 
do
	if [ -h ${f} ] 
	then
		echo "rm ${f}"
		rm ${f}
		echo "cp -a ~/genr_data/${f}" ./
		cp -a ~/genr_data/${f} ./
	else
		echo "already coppied, moving on the 3dresample..."
		
		if [ $RESET -eq 1 ]
		then
			echo "Resetting directory..."
			rsync -aiv ~/genr_data/${f}/ ${f}/
		fi
	fi
			
	boldref=$( find ${f} -regex '.*MNI.*boldref.nii.gz' )
	boldref_bad="${boldref%.nii.gz}_bad.nii.gz"
	mv -v ${boldref} ${boldref_bad}
	3dresample -master ${master} -prefix ${boldref} -input ${boldref_bad}
	echo "Voxel dims in old file: "
	3dinfo -adi -adj -adk ${boldref_bad}
	echo "Voxel dims in resampled file: "
	3dinfo -adi -adj -adk ${boldref}
done 

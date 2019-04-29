#!/bin/bash

filelist_pattern="/data/mounts/scs-fs-20/kpsy/genr/users/jflournoy/linked_subs/*/ses-F09/func/*_space-MNI152NLin2009cAsym_boldref.nii.gz"

ls -1 ${filelist_pattern} >  ~/data/GenR_motion/bold_ref_movie.csv && fslmerge -t ~/data/GenR_motion/bold_ref_movie.nii ${filelist_pattern}

#!/bin/bash

ls -1 /data/mounts/scs-fs-20/kpsy/genr/mrdata/GenR_MRI/bids/derivatives/fmriprep/*/ses-F09/func/*_space-MNI152NLin2009cAsym_boldref.nii.gz >  ~/data/GenR_motion/bold_ref_movie.csv && fslmerge -t ~/data/GenR_motion/bold_ref_movie.nii /data/mounts/scs-fs-20/kpsy/genr/mrdata/GenR_MRI/bids/derivatives/fmriprep/*/ses-F09/func/*_space-MNI152NLin2009cAsym_boldref.nii.gz

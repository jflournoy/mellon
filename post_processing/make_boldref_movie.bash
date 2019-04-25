#!/bin/bash
ls -l */ses-F09/func/*_space-MNI152NLin2009cAsym_boldref.nii.gz > ~/data/GenR_motion/bold_ref_movie.csv && fslmerge -t ~/data/GenR_motion/bold_ref_movie.nii */ses-F09/func/*_space-MNI152NLin2009cAsym_boldref.nii.gz

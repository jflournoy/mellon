#!/bin/bash

python /home/jflournoy/code/mellon/connectivity/extract_connectivity.py -i /home/jflournoy/code/mellon/post_processing/rs_files_and_exclusions.csv -label_img /home/jflournoy/code/mellon/power_spheres/power_drysdale_spheres.nii -label_names /home/jflournoy/code/mellon/power_spheres/power_drysdale_labels.csv -outname power_drysdal -outdir /data/mounts/scs-fs-20/kpsy/genr/users/jflournoy/rsfc_derivatives/ -numcores 10 -verbose 10  

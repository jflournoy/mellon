#!/bin/bash

module load afni

3dUndump -xyz -srad 5 -prefix power_drysdale_spheres.nii -master /net/holynfs01/srv/export/mclaughlin/share_root/users/jflournoy/code/GenR/power_spheres/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c.nii /net/holynfs01/srv/export/mclaughlin/share_root/users/jflournoy/code/GenR/power_spheres/power_drysdale_spheres.ssv 

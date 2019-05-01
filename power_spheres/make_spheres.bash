#!/bin/bash

module load afni

3dUndump -xyz -srad 5 -prefix power_drysdale_spheres.nii -master /home/jflournoy/code/mellon/power_spheres/mni_icbm152_t1_tal_nlin_asym_09c.nii /home/jflournoy/code/mellon/power_spheres/power_drysdale_spheres.ssv 

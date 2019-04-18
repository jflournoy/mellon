#!/bin/bash
#SBATCH --job-name=to_mni
#SBATCH --output=/users/jflournoy/output/custom_template/to_mni_template.out
#SBATCH --error=/users/jflournoy/output/custom_template/to_mni_template.err
#SBATCH --time=4:00:00
#SBATCH --partition=ncf_holy
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=22
#SBATCH --mem=2000M

ncore=`nproc`
mni_template=/mnt/stressdevlab/GenR_derivatives/new_study_template/MNI/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_2mm.nii

# CD to the T1 directory where all the T1 images live
cd /net/holynfs01/srv/export/mclaughlin/share_root/stressdevlab/GenR_derivatives/new_study_template

#Set up ANTS path:
module load ants/2.3.1-ncf

registrationOpts="-n $ncore"

# Nonlinear transform to MNI template
antsRegistrationSyN.sh $registrationOpts -d 3 -f "${mni_template}" -m GRtemplate.nii.gz -o GRtemplateToMNI


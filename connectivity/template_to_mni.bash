#!/bin/bash
#SBATCH --job-name=to_mni
#SBATCH --output=/users/jflournoy/output/custom_template/to_mni_template.out
#SBATCH --error=/users/jflournoy/output/custom_template/to_mni_template.err
#SBATCH --time=4:00:00
#SBATCH --partition=ncf_holy
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=22
#SBATCH --mem=2000M

#Ensure ants is accessible
module load ants/2.3.1-ncf

#Set this to however many processors are available to you.
ncore=`nproc`

#mni template available here: http://www.bic.mni.mcgill.ca/~vfonov/icbm/2009/mni_icbm152_nlin_asym_09c_nifti.zip
mni_template="mni_icbm152_t1_tal_nlin_asym_09c_2mm.nii" 
group_template="/path/to/genr_template_9iter.nii.gz"
group_to_mni_warp_prefix="genr_to_mni"

registrationOpts="-n $ncore"

# Nonlinear transform to MNI template
antsRegistrationSyN.sh $registrationOpts -d 3 -f "${mni_template}" -m "${group_template}" -o "${group_to_mni_warp_prefix}"


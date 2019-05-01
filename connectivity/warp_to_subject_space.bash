#!/bin/bash
#SBATCH --job-name=genr_fmriprep
#SBATCH --output=/users/jflournoy/output/genrtest/genr_%A_%a.out
#SBATCH --error=/users/jflournoy/output/genrtest/genr_%A_%a.err
#SBATCH --time=2-00:00:00
#SBATCH --partition=ncf_holy
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=1
#SBATCH --mem=1000M

#This process is fast and low mem

#subnum of form "sub-1" is the first argument to the script
SUBNUM=$1

ROI_IMAGE="/home/jflournoy/code/mellon/power_spheres/power_drysdale_spheres.nii"
ROI_NAME="power_drysdale" #for naming the warped image
SUB_DIR="/data/mounts/scs-fs-20/kpsy/genr/mrdata/GenR_MRI/bids/derivatives/fmriprep/${SUBNUM}/anat/"
SUB_T1W="${SUB_DIR}/${SUBNUM}_desc-preproc_T1w.nii.gz"
TEMPLATE_DIR="/path/to/study/template/dir/"

cd $SUB_DIR


#Based on the other scripts, these should be the correct names, 
#but might be good to make sure...

TemplateToMNIInvAffine="[${TEMPLATE_DIR}/genr_to_mni0GenericAffine.mat,1]" #1 here specifies it's an inverse transform
TemplateToMNIInvWarp="${TEMPLATE_DIR}/genr_to_mni1InverseWarp.nii.gz"
sub_to_template_inv_affine="[${SUBNUM}_desc-preproc_T1w_to_genr0GenericAffine.mat, 1]"
sub_to_template_inv_warp="${SUBNUM}_desc-preproc_T1w_to_genr1InverseWarp.nii.gz"

#Set up ANTS path:
#Replace with whatever lets you call the ants script directly
module load ants/2.3.1-ncf

#Transform the ROI nii to subject-space as defined by the various 
#affines and warps. Keep in mind that ants applies these in the 
#reverse order of how they're specified. So in this case we first
#apply to the roi nii  
# 1. the inverse template-to-mni affine
# 2. the inverse template-to-mni warp
# 3. the inverse subject-T1w-to-template affine
# 4. the inverse subject-T1w-to-template warp
#Then we save out the file within the subject directory using
#the subject number and roi name.

antsApplyTransforms -i "${ROI_IMAGE}" -r "${SUB_T1W}" -t "${sub_to_template_inv_warp}" "${sub_to_template_inv_affine}" "${TemplateToMNIInvWarp}" "${TemplateToMNIInvAffine}" -o "${SUBNUM}-${ROI_NAME}_warped.nii"


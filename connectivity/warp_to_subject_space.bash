#!/bin/bash
#SBATCH --job-name=genr_fmriprep
#SBATCH --output=/users/jflournoy/output/genrtest/genr_%A_%a.out
#SBATCH --error=/users/jflournoy/output/genrtest/genr_%A_%a.err
#SBATCH --time=2-00:00:00
#SBATCH --partition=ncf_holy
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=1

#subnum of form "sub-1" is the first argument to the script
SUBNUM=$1

ROI_IMAGE="/path/to/roi_image.nii"
ROI_NAME="power" #for naming the warped image
SUB_DIR="/path/to/fmriprep/output/${SUBNUM}/anat/"
SUB_T1W="${SUB_DIR}/${SUBNUM}_desc-preproc_T1w.nii.gz"

cd $SUB_DIR

MNItoTemplateAffine="[genr_to_mni0GenericAffine.mat,1]" #1 here specifies it's an inverse transform
MNItoTemplateWarp="genr_to_mni1InverseWarp.nii.gz"
sub_to_template_affine="[${SUBNUM}_desc-preproc_T1w_to_genrAffine.txt, 1]"
sub_to_template_warp="${SUBNUM}_desc-preproc_T1w_to_genrInverseWarp.nii.gz"

ncore=1

cd $SUB_DIR

#Set up ANTS path:
module load ants/2.3.1-ncf

#Build T1 template:

antsApplyTransforms -i "${ROI_IMAGE}" -r "${SUB_T1W}" -t "${sub_to_template_warp}" "${sub_to_template_affine}" "${MNItoTemplateWarp}" "${MNItoTemplateAffine}" -o "${SUBNUM}-${ROI_NAME}_warped.nii"


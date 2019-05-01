#!/bin/bash
#SBATCH --job-name=genr_fmriprep
#SBATCH --output=/users/jflournoy/output/genrtest/calcwarpt1w.out
#SBATCH --error=/users/jflournoy/output/genrtest/calcwarpt1w.err
#SBATCH --time=2-00:00:00
#SBATCH --partition=ncf_holy
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=1
#SBATCH --mem=8000M

#Set up ANTS path:
module load ants/2.3.1-ncf

GROUP_TEMPLATE="/net/holynfs01/srv/export/mclaughlin/share_root/stressdevlab/GenR_derivatives/new_study_template/GRtemplate.nii.gz"

#subnum of form "sub-1" is the first argument to the script
SUBNUM=$1

SUB_DIR="/net/holynfs01/srv/export/mclaughlin/share_root/stressdevlab/GenR_derivatives/fmriprep/${SUBNUM}/anat/"

cd $SUB_DIR

sub_t1w="${SUB_DIR}/${SUBNUM}_desc-preproc_T1w.nii.gz"
sub_to_genr_warp_prefix="${SUBNUM}_desc-preproc_T1w_to_genr"

ncore=1
registrationOpts="-n $ncore"

# Nonlinear transform to MNI template
antsRegistrationSyN.sh $registrationOpts -d 3 -f "${GROUP_TEMPLATE}" -m "${sub_t1w}" -o "${sub_to_genr_warp_prefix}"


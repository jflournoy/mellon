#!/bin/bash
#SBATCH --job-name=genr_fmriprep
#SBATCH --output=/users/jflournoy/output/genrtest/genr_%A_%a.out
#SBATCH --error=/users/jflournoy/output/genrtest/genr_%A_%a.err
#SBATCH --time=2-00:00:00
#SBATCH --partition=ncf_holy
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=8
#SBATCH --mem=30000M

SUBNUM=$SLURM_ARRAY_TASK_ID

transforms_dir="/net/holynfs01/srv/export/mclaughlin/share_root/stressdevlab/GenR_derivatives/new_study_template/"
MNItoTemplateAffine="[GRtemplateToMNI0GenericAffine.mat,1]"
MNItoTemplateWarp="GRtemplateToMNI1InverseWarp.nii.gz"
TemplatetoSubAffine="[GRsub-${SUBNUM}_desc-preproc_T1wAffine.txt, 1]"
TemplatetoSubWarp="GRsub-${SUBNUM}_desc-preproc_T1wInverseWarp.nii.gz"
SUB_DIR=
ncore=`nproc`

# CD to the T1 directory where all the T1 images live
cd $SUB_DIR


#Set up ANTS path:
module load ants/2.3.1-ncf

#Build T1 template:

antsApplyTransforms -i $(word 1,$^) -r $(MNI_BRAIN) -t $(DT_REG_PREFIX)_1Warp.nii.gz $(DT_REG_PREFIX)_0GenericAffine.mat xfm_dir/T1_to_custom_s_1Warp.nii.gz  xfm_dir/T1_to_custom_s_0GenericAffine.mat  xfm_dir/$${TASK}/$${RUN}_to_T1_r_0GenericAffine.mat -o $@ ;\

exit

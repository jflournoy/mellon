#!/bin/bash
#SBATCH --job-name=gr_template
#SBATCH --output=/users/jflournoy/output/custom_template/template.out
#SBATCH --error=/users/jflournoy/output/custom_template/template.err
#SBATCH --time=1-00:00:00
#SBATCH --partition=ncf_holy
#SBATCH --mail-type=END,FAIL
#SBATCH --cpus-per-task=22
#SBATCH --mem=60000M

ncore=`nproc`

# CD to the T1 directory where all the T1 images live
cd /net/holynfs01/srv/export/mclaughlin/share_root/stressdevlab/GenR_derivatives/new_study_template

#Set up ANTS path:
module load ants/2.3.1-ncf

#Build T1 template:
buildtemplateparallel.sh -d 3 -o GR -c 2 -j 22 *T1w.nii.gz
exit

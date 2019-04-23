#!/bin/bash
ls -ltd ~/genr_data/sub-*/|grep genr_mri|sed 's/.*\(sub-.*\)\//\1/'|sort > subject_list.txt 

#!/bin/bash

# Matteo Bastiani
# 26/05/2020


if [ "$3" == "" ];then
    echo ""
    echo "usage: $0 <reference volume> <source volume> <ANTS basename>"
    echo "       Converts ANTS warpfield to FSL FNIRT"
    echo "       "
    echo "       reference volume: fixed image"
    echo "       source volume: moving image"
    echo "       ANTS basename: output basename used with ANTS (must included full path if not in the same folder)"
    echo "       "
    echo ""
    exit 1
fi


refVol=$1          # Path to the subject folder
srcVol=$2                 # Subject T2-weighted volume
antsBase=$3                  # White matter segmentation volume (0=do not use BBR)


antsDir=`dirname ${antsBase}`

${C3DPATH}/c3d_affine_tool -ref ${refVol} -src ${srcVol} -itk ${antsBase}0GenericAffine.mat \
			   		       -ras2fsl -o ${antsBase}affine_flirt.mat
${C3DPATH}/c3d -mcs ${antsBase}1Warp.nii.gz -oo ${antsDir}/wx.nii.gz ${antsDir}/wy.nii.gz ${antsDir}/wz.nii.gz

${FSLDIR}/bin/fslmaths ${antsDir}/wy -mul -1 ${antsDir}/i_wy
${FSLDIR}/bin/fslmerge -t ${antsBase}warp_fnirt ${antsDir}/wx ${antsDir}/i_wy ${antsDir}/wz
${FSLDIR}/bin/convertwarp --ref=${refVol} --premat=${antsBase}affine_flirt.mat \
			  	           --warp1=${antsBase}warp_fnirt --out=${antsDir}/src2ref_warp

${FSLDIR}/bin/invwarp -w ${antsDir}/src2ref_warp -o ${antsDir}/ref2src_warp -r ${srcVol}



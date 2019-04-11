#!/bin/bash

## THis script is going to be used to organize the dicoms that did not make it through heudiconv
## For Cobb's NRCO data set
## The basic set up of this script is I am going to organize the data based on the dicom header information
## I will be adding information about this throughout the comments
## Essentially I will be going through the header, first looking for the 0018 0024 dicom field
## This field contains the "ACQ Sequence Name"
## Here is the key for "ACQ Sequence Name" --> prtocol name:
##  1.) *tfl3d1_ns --> mprage
##  2.) *epfid2d1_64 --> bbl1_resting_150 | bbl1_swm_run1_286 | bbl1_resting_90 | bbl1_swm_run2_271 | bbl1_resting_90 | bbl1_swm_run3_281 | bbl1_resting_150
##  3.) fm2d2r --> gre_field_mapping
##  4.) *ep_b1000* --> bbl1_ep2d_diff_64_AP_dir

## The basic flow of this script is going to be:

## A. Anatomical
##  1. Go through all of the subjects that do not have BIDS organized directories
##  2. W/in their organized raw data, go through and identify the dicoms that are there for the anatomical scan
##  3. isolate these dicoms, and run dcm2niix on these dicoms, and then organize the anatomical into
## the bids data structure

## B. Functional
##  1. Follow A.1-3 but this will have to iterate through all functional sequeneces

## C. Diffusion - I do not know the best way to run through diffusion, will most likley follow as above

## First identify subjects of interest

for i in `find /data/joy/BBL/studies/nrco/rawData/organizedRaw/ -name "*CO*" -type d -maxdepth 1 | rev | cut -f 1 -d . | rev` ; do ls joy/BBL/studies/nrco/BIDS/*${i}* ; done 2> ~/foobar

export PATH=/data/joy/BBL/applications/mricrogl_lx:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/joy/BBL/applications/glibc-2.14/lib

## Now go through each subject that we did not find
for q in `cat ~/foobar | cut -f 4 -d ' ' | cut -f 2 -d "*"` ; do
  ### fnd the full subject identifier
  fullID=`find /data/joy/BBL/studies/nrco/rawData/organizedRaw/ -maxdepth 1 -name "*${q}*" -type d`
  redID=`find /data/joy/BBL/studies/nrco/rawData/organizedRaw/ -maxdepth 1 -name "*${q}*" -type d | rev | cut -f 1 -d / | rev`
  redID=`echo ${redID//.}`
  echo ${redID}
  ## Now make a tmp directory in the path of interest
  tmpDir="${fullID}/tmpStore"
  mkdir -p ${tmpDir}


  ## Now change to the correct directory
  ## Now go through all of the dicoms in the organized directory and find all that mathc the mprage name
  primeerVal=0
  for z in `ls ${fullID}/*` ; do
    fieldToCheck=`dicom_hdr ${z} | grep "0018 0024" | rev | cut -f 1 -d '/' | rev | cut -f 2 -d '*'`;
    if [ "${fieldToCheck}" == "tfl3d1_ns" ] ; then
      echo "success"
      echo "${z}"
      echo ${fileToCheck}
      primeerVal=`echo ${primeerVal} + 1 | bc`
      cp ${z} ${tmpDir}/
    fi
  done
  echo ${primeerVal}
  ## Now if the primeerVal is > 0 lets orginze the dicoms into the proper channels
  if [ ${primeerVal} -gt 0  ] ; then
    dcm2niix -z i ${tmpDir}/* ;
  fi
primeerVal=0
for z in `ls ${fullID}/*IMA` ; do
fieldToCheck=`dicom_hdr ${z} | grep "0018 0024" | rev | cut -f 1 -d '/' | rev | cut -f 2 -d '*'`;
if [ "${fieldToCheck}" == "tfl3d1_ns" ] ; then
echo "success"
echo "${z}"
echo ${fileToCheck}
primeerVal=`echo ${primeerVal} + 1 | bc`
cp ${z} ${tmpDir}/
fi
done
echo ${primeerVal}
## Now if the primeerVal is > 0 lets orginze the dicoms into the proper channels
if [ ${primeerVal} -gt 0  ] ; then
dcm2niix -z i ${tmpDir}/* ;
fi

  ## Now find the nifti images with the correct number of dimensions
  runIndex=1
  for Image in `find ${tmpDir}/ -name "*nii.gz"` ; do
    dim1=`fslinfo ${Image} | grep "^dim1" | rev | cut -f 1 -d ' ' | rev`
    dim2=`fslinfo ${Image} | grep "^dim2" | rev | cut -f 1 -d ' ' | rev`
    dim3=`fslinfo ${Image} | grep "^dim3" | rev | cut -f 1 -d ' ' | rev`
    dimSum=`echo ${dim1} + ${dim2} + ${dim3} | bc`
    if [  ${dimSum}  -eq 688 ] ; then
      bidsDir="/data/joy/BBL/studies/nrco/BIDS/sub-${redID}"
      anatDir="${bidsDir}/anat/"
      mkdir -p ${anatDir}
      targetName="${anatDir}/sub-${redID}_run-${runIndex}_T1w.nii.gz"
      mv -f ${Image} ${targetName}
      ## Now move the json
      json_name=`remove_ext ${Image}`
      json_name="${json_name}.json"
      targetName="${anatDir}/sub-${redID}_run-${runIndex}_T1w.json"
      mv -f ${json_name} ${targetName}
      runIndex=`echo ${runIndex} + 1 | bc`;
    fi
  done
done

## Remvoe all temp data
find /data/joy/BBL/studies/nrco/rawData/organizedRaw/ -name "tmpStore" -type d | xargs rm -rf

#### Now do the diffusion data down here
## Now go through each subject that we did not find
for q in `cat ~/foobar | cut -f 4 -d ' ' | cut -f 2 -d "*"` ; do
### fnd the full subject identifier
fullID=`find /data/joy/BBL/studies/nrco/rawData/organizedRaw/ -maxdepth 1 -name "*${q}*" -type d`
redID=`find /data/joy/BBL/studies/nrco/rawData/organizedRaw/ -maxdepth 1 -name "*${q}*" -type d | rev | cut -f 1 -d / | rev`
redID=`echo ${redID//.}`
echo ${redID}
## Now make a tmp directory in the path of interest
tmpDir="${fullID}/tmpStore"
mkdir -p ${tmpDir}


## Now change to the correct directory
## Now go through all of the dicoms in the organized directory and find all that mathc the mprage name
primeerVal=0
for z in `ls ${fullID}/*` ; do
fieldToCheck=`dicom_hdr ${z} | grep "0018 0024" | rev | cut -f 1 -d '/' | rev | cut -f 2 -d '*'`;
if [ "${fieldToCheck:0:4}" == "ep_b" ] ; then
echo "success"
echo "${z}"
echo ${fileToCheck}
primeerVal=`echo ${primeerVal} + 1 | bc`
cp ${z} ${tmpDir}/
fi
done
echo ${primeerVal}
## Now if the primeerVal is > 0 lets orginze the dicoms into the proper channels
if [ ${primeerVal} -gt 0  ] ; then
dcm2niix -z i ${tmpDir}/* ;
fi

## Now find the nifti images with the correct number of dimensions
runIndex=1
for Image in `find ${tmpDir}/ -name "*nii.gz"` ; do
dim1=`fslinfo ${Image} | grep "^dim1" | rev | cut -f 1 -d ' ' | rev`
dim2=`fslinfo ${Image} | grep "^dim2" | rev | cut -f 1 -d ' ' | rev`
dim3=`fslinfo ${Image} | grep "^dim3" | rev | cut -f 1 -d ' ' | rev`
dimSum=`echo ${dim1} + ${dim2} + ${dim3} | bc`
if [  ${dimSum}  -eq 688 ] ; then
bidsDir="/data/joy/BBL/studies/nrco/BIDS/sub-${redID}"
anatDir="${bidsDir}/anat/"
mkdir -p ${anatDir}
targetName="${anatDir}/sub-${redID}_run-${runIndex}_T1w.nii.gz"
mv -f ${Image} ${targetName}
## Now move the json
json_name=`remove_ext ${Image}`
json_name="${json_name}.json"
targetName="${anatDir}/sub-${redID}_run-${runIndex}_T1w.json"
mv -f ${json_name} ${targetName}
runIndex=`echo ${runIndex} + 1 | bc`;
fi
done
done

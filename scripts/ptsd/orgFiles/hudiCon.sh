#!/bin/bash

## Decalare any statics

singularity=/share/apps/singularity/2.5.1/bin/singularity

# obtain scan and session labels
scans=/data/joy/BBL/studies/ptsd/rawData/*/*/
user=`whoami`
mkdir -p ~/data
## Now copy the projects directory with all of the heudiconv 
cp -r /data/jux/BBL/projects/ptsd-mri-org/scripts/projects ~/
## This first for loop sets up all of the scans in the <sub>/<ses> format
for sc in $scans;  do

  ses=$(echo $sc|cut -d'/' -f9);
  echo ${ses}
  subID=$(echo $sc|cut -d'/' -f8);
  echo ${subID}
  singularity=/share/apps/singularity/2.5.1/bin/singularity
  # USE SINGULARITY HERE TO RUN HEUDICONV FOR BIDS FORMATTING
  echo "$singularity run -B /data/joy/BBL/studies/ptsd/rawData:/home/${user}/data /data/joy/BBL/applications/heudiconv/heudiconv-latest.simg -d /home/${user}/data/{subject}/{session}/* -o /home/${user}/data/joy/BBL/studies/ptsd/BIDS/ -f /home/${user}/projects/nrco_bids/ptsd_heur.py -s ${subID} -ss ${ses}  -c dcm2niix -b --overwrite" > ~/${ses}_${subID}_singl.sh
  qsub -q basic.q,all.q -l h_vmem=4.0G,s_vmem=4.0G ~/${ses}_${subID}_singl.sh

done

## Add in a buffer so we can finish all of the qsub jobs
qstatRem=`qstat | wc -l`
while [ ${qstatRem} -gt 0 ] ; do
  echo "$qstatRem jobs still remaining"
  qstatRem=`qstat | wc -l`
  sleep 30
done


## Now sync the files into the correct location
rsync -r /data/joy/BBL/studies/ptsd/rawData/joy/BBL/studies/ptsd/BIDS /data/joy/BBL/studies/ptsd/

## THis loop is run so we can organize the T1's in a specific format so freesurfer will be run on all, and not the full long pipeline
scans=/data/joy/BBL/studies/ptsd/rawData/*/*/
for sc in $scans;  do

  ses=$(echo $sc|cut -d'/' -f9);
  echo ${ses}
  subID=$(echo $sc|cut -d'/' -f8);
  echo ${subID}
  singularity=/share/apps/singularity/2.5.1/bin/singularity
  # USE SINGULARITY HERE TO RUN HEUDICONV FOR BIDS FORMATTING
  echo "$singularity run -B /data/joy/BBL/studies/ptsd/rawData:/home/${user}/data /data/joy/BBL/applications/heudiconv/heudiconv-latest.simg -d /home/${user}/data/{subject}/{session}/* -o /home/${user}/data/joy/BBL/studies/ptsd/BIDST1/ -f /home/${user}/projects/nrco_bids/ptsd_heur-T1.py -s ${subID} -ss ${ses}  -c dcm2niix -b --overwrite" > ~/${ses}_${subID}_T1singl.sh
  qsub -q basic.q,all.q -l h_vmem=4.0G,s_vmem=4.0G ~/${ses}_${subID}_T1singl.sh

done

## Now add in a buffer so we can finish all of the qsub jobs
qstatRem=`qstat | wc -l`
while [ $qstatRem -gt 0 ] ; do
  echo "$qstatRem jobs still remaining"
  qstatRem=`qstat | wc -l`
  sleep 30
done
echo "Now Organizing and cleaning files"
## Now sync the files into the correct location
rsync -r /data/joy/BBL/studies/ptsd/rawData/joy/BBL/studies/ptsd/BIDST1 /data/joy/BBL/studies/ptsd/
## Now clean up the wrong path
rm -rf /data/joy/BBL/studies/ptsd/rawData/joy


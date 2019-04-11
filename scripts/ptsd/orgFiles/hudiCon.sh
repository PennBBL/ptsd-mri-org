

# obtain scan and session labels
scans=/data/joy/BBL/studies/ptsd/rawData/*/*/

## This first for loop sets up all of the scans in the <sub>/<ses> format
for sc in $scans;  do

  ses=$(echo $sc|cut -d'/' -f9);
  echo ${ses}
  subID=$(echo $sc|cut -d'/' -f8);
  echo ${subID}
  singularity=/share/apps/singularity/2.5.1/bin/singularity
  # USE SINGULARITY HERE TO RUN HEUDICONV FOR BIDS FORMATTING

  echo "$singularity run -B /data/joy/BBL/studies/ptsd/rawData:/home/arosen/data /data/joy/BBL/applications/heudiconv/heudiconv-latest.simg -d /home/arosen/data/{subject}/{session}/* -o /home/arosen/data/joy/BBL/studies/ptsd/BIDS/ -f /home/arosen/projects/nrco_bids/ptsd_heur.py -s ${subID} -ss ${ses}  -c dcm2niix -b --overwrite" >> ~/${ses}_${subID}_singl.sh
  qsub ~/${ses}_${subID}_singl.sh

done



## THis loop is run so we can organize the T1's in a specific format so freesurfer will be run on all, and not the full long pipeline
scans=/data/joy/BBL/studies/ptsd/rawData/*/*/
for sc in $scans;
do

ses=$(echo $sc|cut -d'/' -f9);
echo ${ses}
subID=$(echo $sc|cut -d'/' -f8);
echo ${subID}
singularity=/share/apps/singularity/2.5.1/bin/singularity
# USE SINGULARITY HERE TO RUN HEUDICONV FOR BIDS FORMATTING
# note to replace axu with your chead name instead

echo "$singularity run -B /data/joy/BBL/studies/ptsd/rawData:/home/arosen/data /data/joy/BBL/applications/heudiconv/heudiconv-latest.simg -d /home/arosen/data/{subject}/{session}/* -o /home/arosen/data/joy/BBL/studies/ptsd/BIDST1/ -f /home/arosen/projects/nrco_bids/ptsd_heur.py -s ${subID} -ss ${ses}  -c dcm2niix -b --overwrite" >> ~/${ses}_${subID}_singl.sh
qsub ~/${ses}_${subID}_singl.sh

done

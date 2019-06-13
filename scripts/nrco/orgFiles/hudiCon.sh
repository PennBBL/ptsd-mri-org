## Declare static vars
user=`whoami`
SINGULARITY=/share/apps/singularity/2.5.1/bin/singularity
mkdir -p ~/data
## Now copy the projects directory with all of the heudiconv 
cp -r /data/jux/BBL/projects/ptsd-mri-org/scripts/projects ~/

## Run all of these through a loop and submit the jobs to the grid
mkdir ~/data
scans=/data/joy/BBL/studies/nrco/rawData/organizedRaw/*/
for sc in $scans;  do
  subID=$(echo $sc|cut -d'/' -f9);
  echo ${ses}
  singularity=/share/apps/singularity/2.5.1/bin/singularity
  echo "$singularity run -B /data/joy/BBL/studies/nrco/rawData/organizedRaw/:/home/${user}/data /data/joy/BBL/applications/heudiconv/heudiconv-latest.simg -d /home/${user}/data/{subject}/* -o /home/${user}/data/joy/BBL/studies/nrco/BIDS/ -f /home/arosen/projects/nrco_bids/nrco_heur.py -s ${subID}  -c dcm2niix -b --overwrite" > ~/e${subID}_singl.sh
  qsub -q basic.q,all.q -l h_vmem=4.0G,s_vmem=4.0G ~/e${subID}_singl.sh

done

## Add in a buffer so we can finish all of the qsub jobs
qstatRem=`qstat | wc -l`
while [ $qstatRem -gt 0 ] ; do
  echo "$qstatRem jobs still remaining"
  qstatRem=`qstat | wc -l`
  sleep 30
done
echo "Now Organizing and cleaning files"
## Now sync the files into the correct location
rsync -r /data/joy/BBL/studies/nrco/rawData/organizedRaw/joy/BBL/studies/nrco/BIDS /data/joy/BBL/studies/nrco/
## Now clean up the wrong path
rm -rf /data/joy/BBL/studies/nrco/rawData/organizedRaw/joy

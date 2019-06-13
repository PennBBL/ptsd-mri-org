unset PYTHONPATH
unalias python

## Declare static vars
user=`whoami`
PYTHON=/data/joy/BBL/applications/miniconda3/envs/py2k/bin/python
SINGULARITY=/share/apps/singularity/2.5.1/bin/singularity
SIMG=/data/joy/BBL/applications/heudiconv/heudiconv-latest.simg
HEURISTIC=/home/${user}/projects/nrco_bids/grmpy_heuristics.py


BIDS_DIR=/data/joy/BBL/studies/ptsd/BIDS/${scan_id}
TMP_BIND=/home/${whoami}/${TMPDIR}
mkdir -p ${TMP_BIND}
cd ${TMPDIR}

## Organize the dicoms
cd /data/jux/BBL/studies/nrco/rawData/dicomDump
for i in `find . -name "*co*" -type d | cut -f 2 -d /` ; do
  for q in `find ../orig/subjects/${i} -name "*dcm" -type f` ; do
    cp ${q} ./${i}/ ;
  done ;
done


## Run all of these through a loop and submit the jobs to the grid
mkdir ~/data
scans=/data/joy/BBL/studies/nrco/rawData/organizedRaw/*/
for sc in $scans;  do
  subID=$(echo $sc|cut -d'/' -f9);
  echo ${ses}
  singularity=/share/apps/singularity/2.5.1/bin/singularity
  echo "$singularity run -B /data/joy/BBL/studies/nrco/rawData/organizedRaw/:/home/${user}/data /data/joy/BBL/applications/heudiconv/heudiconv-latest.simg -d /home/${user}/data/{subject}/* -o /home/${user}/data/joy/BBL/studies/nrco/BIDS/ -f /home/${user}/projects/nrco_bids/nrco_heur.py -s ${subID}  -c dcm2niix -b --overwrite" > ~/e${subID}_singl.sh
  #qsub -l h_vmem=4.0G,s_vmem=4.0G ~/e${subID}_singl.sh

done

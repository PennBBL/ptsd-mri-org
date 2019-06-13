cp /share/apps/freesurfer/6.0.0/license.txt  /home/arosen/license.txt

mkdir -p /home/arosen/data

for idw in `find /data/joy/BBL/studies/ptsd/BIDS/sub-DM* -mindepth 1 -maxdepth 1 | rev | cut -f 2 -d / | rev | cut -f 2 -d - | uniq` ; do

  echo /share/apps/singularity/2.5.1/bin/singularity run -B /data:/home/arosen/data /data/joy/BBL/applications/bids_apps/freesurfer.simg /home/arosen/data/joy/BBL/studies/ptsd/BIDS/ /home/arosen/data/joy/BBL/studies/ptsd/processedData/freesurfer60/ participant --participant_label ${idw} --license_file /home/arosen/data/joy/BBL/studies/ptsd/processedData/freesurfer60/license.txt --skip_bids_validator  --steps cross-sectional > subjectrun${idw}.sh

  qsub  -l h_vmem=8.0G,s_vmem=8.0G  subjectrun${idw}.sh ;

done


for idw in `find /data/joy/BBL/studies/ptsd/BIDST1/sub-DM* -mindepth 1 -maxdepth 1 | rev | cut -f 2 -d / | rev | cut -f 2 -d - | uniq` ; do

  echo /share/apps/singularity/2.5.1/bin/singularity run -B /data:/home/arosen/data /data/joy/BBL/applications/bids_apps/freesurfer.simg /home/arosen/data/joy/BBL/studies/ptsd/BIDST1/ /home/arosen/data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60NoAvg/ participant --participant_label ${idw} --license_file /home/arosen/data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60/license.txt --skip_bids_validator > subjectrunFSCS${idw}.sh

  qsub  -l h_vmem=8.0G,s_vmem=8.0G  subjectrunFSCS${idw}.sh ;

done

### here are the group calls
/share/apps/singularity/2.5.1/bin/singularity run -B /data:/home/arosen/data /data/joy/BBL/applications/bids_apps/freesurfer.simg /home/arosen/data/joy/BBL/studies/ptsd/BIDST1/ /home/arosen/data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60NoAvg/ group1 --license_file /home/arosen//data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60/license.txt 

/share/apps/singularity/2.5.1/bin/singularity run -B /data:/home/arosen/data /data/joy/BBL/applications/bids_apps/freesurfer.simg /home/arosen/data/joy/BBL/studies/ptsd/BIDST1/ /home/arosen/data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60NoAvg/ group2 --license_file /home/arosen//data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60/license.txt --skip_bids_validator

## Now do fmriprep
for idw in `find /data/joy/BBL/studies/ptsd/BIDS/sub-DM* -mindepth 1 -maxdepth 1 | rev | cut -f 2 -d / | rev | cut -f 2 -d - | uniq` ; do

  echo /share/apps/singularity/2.5.1/bin/singularity run -B /data:/home/arosen/data /data/joy/BBL/applications/bids_apps/fmriprep.simg /home/arosen/data/joy/BBL/studies/ptsd/BIDS/ /home/arosen/data/joy/BBL/studies/ptsd/processedData/fmriPrep/ participant --participant_label ${idw} --skip_bids_validation --fs-license-file /home/arosen/data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60/license.txt > s${idw}FMRIP.sh

  qsub  -l h_vmem=12.0G,s_vmem=12.0G  s${idw}FMRIP.sh ;

done

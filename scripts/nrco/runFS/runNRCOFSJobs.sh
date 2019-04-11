## This section runs FS for the nrco data
for idw in `find /data/joy/BBL/studies/nrco/BIDS/sub-* -mindepth 1 -maxdepth 1 | rev | cut -f 2 -d / | rev | cut -f 2 -d - | uniq` ; do
echo ${idw}
echo /share/apps/singularity/2.5.1/bin/singularity run -B /data:/home/arosen/data /data/joy/BBL/applications/bids_apps/freesurfer.simg /home/arosen/data/joy/BBL/studies/nrco/BIDS/ /home/arosen/data/joy/BBL/studies/nrco/processedData/anatomical/freesurfer60 participant --participant_label ${idw} --license_file /home/arosen/data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60/license.txt --skip_bids_validator > ~/subjectrunFSCS${idw}.sh

qsub  -q basic.q,all.q -l h_vmem=10.0G,s_vmem=10.0G /home/arosen/subjectrunFSCS${idw}.sh ;

done

/share/apps/singularity/2.5.1/bin/singularity run -B /data:/home/arosen/data /data/joy/BBL/applications/bids_apps/freesurfer.simg /home/arosen/data/joy/BBL/studies/nrco/BIDS/ /home/arosen/data/joy/BBL/studies/nrco/processedData/anatomical/freesurfer60/ group1 --license_file /home/arosen//data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60/license.txt

/share/apps/singularity/2.5.1/bin/singularity run -B /data:/home/arosen/data /data/joy/BBL/applications/bids_apps/freesurfer.simg /home/arosen/data/joy/BBL/studies/nrco/BIDS/ /home/arosen/data/joy/BBL/studies/nrco/processedData/anatomical/freesurfer60/ group2 --license_file /home/arosen//data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60/license.txt

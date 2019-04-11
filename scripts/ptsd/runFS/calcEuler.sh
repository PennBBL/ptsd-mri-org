mkdir -p /data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60NoAvg/tmpGroupEuler
for i in `find /data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60NoAvg -mindepth 1 -maxdepth 1 -type d -name "sub-*_ses*" | cut -f 1 -d '.' | sort | uniq` ; do
  ## First decalre all of the info we will need
  subjID=`echo ${i} | rev | cut -f 1 -d / | rev`
  surfDir="${i}/surf/"
  statDir="${i}/stats/"
  ## Now declare the output file
  outputFile=${statDir}${subjID}_eulerVals.csv
  ## Now write the header to the output
  echo "subject,leftEuler,rightEuler" > ${outputFile}
  ## Now obtain our values
  # First start with the left hemi
  leftVal=`script -c "mris_euler_number ${surfDir}lh.orig.nofix" | grep ">" | cut -d ">" -f 1 | cut -d "=" -f 4 | cut -d " " -f 2`
  rightVal=`script -c "mris_euler_number ${surfDir}rh.orig.nofix" | grep ">" | cut -d ">" -f 1 | cut -d "=" -f 4 | cut -d " " -f 2`
  ## Now write the output
  echo ${subjID},${leftVal},${rightVal} >> ${outputFile} 
  ## Now cp this to the group tmp dir
  cp ${outputFile} /data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60NoAvg/tmpGroupEuler/ ; 
done

cd /data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60NoAvg/tmpGroupEuler
~/adroseHelperScripts/bash/mergeCSV.sh
mv /data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60NoAvg/tmpGroupEuler/merged.csv /data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60NoAvg/ptsdEuler.csv
rm -rf /data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60NoAvg/tmpGroupEuler

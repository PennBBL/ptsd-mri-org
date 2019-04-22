# Source AFGR helper func
source("~/adroseHelperScripts/R/afgrHelpFunc.R")

dat.one <- read.csv("/data/joy/BBL/studies/nrco/processedData/anatomical/freesurfer60/nrcoEuler.csv")
dat.one$meanEuler <- apply(dat.one[,2:3], 1, mean)
dat.two <- read.csv("/data/joy/BBL/studies/ptsd/processedData/anatomical/freesurfer60NoAvg/ptsdEuler.csv")
dat.two$meanEuler <- apply(dat.two[,2:3], 1, mean)

## Now we need to combine these data frames and sort them by the lowest euler values
all.dat <- rbind(dat.one, dat.two)
all.dat <- all.dat[order(as.numeric(as.character(all.dat$meanEuler))),]

## Now go through the images and flag unusable ones
all.dat$manRat <- 2
## First identify all nrco data
all.dat$dataset <- 'ptsd'
all.dat$dataset[grep(x=all.dat$subject, pattern='CO', ignore.case=T)] <- 'nrco'
for(i in 245:247){
  ## Dataset need to be handeled different so identify if we are working with nrco or ptsd
  if(all.dat$dataset[i]=='ptsd'){
    command.string.1 <- "/data/joy/BBL/studies/ptsd/BIDST1/"
    subj.string <- strSplitMatrixReturn(all.dat[i,'subject'], '_')[,1]
    ses.string <- strSplitMatrixReturn(all.dat[i,'subject'], 'ses')[,2]
    ## Now grab the full string
    full.string <- paste(command.string.1, subj.string, '/ses', ses.string, '/anat/*nii.gz', sep='')
    ## Return some info here
    print(paste("Subject ID: ", subj.string))
    print(paste("Image path: ", full.string))
    ## Now run fslview
    system(paste("fslview", full.string))
    ## Now ask for quality assessment
    all.dat$manRat[i]<-readline(paste("Select one of the following: \n \t please enter 0, 1, or 2: \n Enter Your Response HERE:   ",sep=""))
  }
    if(all.dat$dataset[i]=='nrco'){
    command.string.1 <- "/data/joy/BBL/studies/nrco/BIDS/"
    subj.string <- all.dat$subject[i]
    ## Now grab the full string
    full.string <- paste(command.string.1, subj.string,'/anat/*nii.gz', sep='')
    ## Return some info here
    print(paste("Subject ID: ", subj.string))
    print(paste("Image path: ", full.string))
    ## Now run fslview
    system(paste("fslview", full.string))
    ## Now ask for quality assessment
    all.dat$manRat[i]<-readline(paste("Select one of the following: \n \t please enter 0, 1, or 2: \n Enter Your Response HERE:   ",sep=""))
  }
}

## Now write the output
write.csv(all.dat, "/data/jux/BBL/projects/ptsd-mri-org/data/manualRatingValues.csv", quote=F, row.names=F)


# load features
source("basicInfo.R")
source("EBImageFeatures.R")
source("colorFeatures.R")

# set default values
listFile <- "sample.txt"
resultFile <- "results.txt"
logFile <- "log.txt"

# load arguments
cargs <- Sys.getenv(c('listFile','resultFile','logFile'))

if (nchar(cargs[1]) > 0) listFile <- cargs[1];
if (nchar(cargs[2]) > 0) resultFile <- cargs[2];
if (nchar(cargs[3]) > 0) logFile <- cargs[3]

# read list of filenames
fin <- file(listFile,"r")
files <- readLines(fin)
n <- length(files)
close(fin)

# create output
fon <- file(resultFile,"w")


# for each file
for(i in 1:n) {
  f <- files[i]

  v1 <- basicInfo(f)
  v2 <- EBImageFeatures(f)
  v3 <- colorFeatures(f)

  v <- c(v1,v2,v3)

  # also print header if it's the first line
  if (i == 1) {
     cat(names(v),"\n",file=fon,sep=",")
     cat("string",rep("float",length(v)),"\n",file=fon,sep=",")
  }
       
  # print feature values
  cat(f,v,"\n",file=fon,sep=",")
}

# close output
close(fon)
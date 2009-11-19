
# basic summary from a given jpeg

library("biOps")

basicInfo <- function(f) {
  # read jpeg
  I <- readJpeg(f)
  # convert to grayscale
  Ig <- imgRGB2Grey(I)
  vIg <- as.vector(Ig)
  # compute summary
  s <- summary(vIg)
  retval <- c(s,Stdev=sd(vIg))
  return(retval)
}


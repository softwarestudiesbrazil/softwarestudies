
library("EBImage")

EBImageFeatures <- function(f) {
  I <- readImage(f)
  Id <- imageData(I)
  # RGB2GRAY
  Ig <- Id[,,1]*.3+Id[,,2]*.59+Id[,,3]*.11
  mask <- matrix(1,dim(I)[[1]],dim(I)[[2]])
  v <- getFeatures(mask,Ig)[[1]]
  return(v[1,])
}

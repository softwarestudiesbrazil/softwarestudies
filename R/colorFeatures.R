
library("colorspace")
library("EBImage")

colorFeatures <- function(f) {
  I <- readImage(f)
  Id <- imageData(I)
  # extract RGB
  R <- as.vector(Id[,,1])
  G <- as.vector(Id[,,2])
  B <- as.vector(Id[,,3])
  rgb <- RGB(R,G,B)
  # convert to HSV
  hsv <- coords(as(rgb,"HSV"))
  retval <- c(summary(hsv[,1]),summary(hsv[,2]),summary(hsv[,3]))  
  return(retval)
}
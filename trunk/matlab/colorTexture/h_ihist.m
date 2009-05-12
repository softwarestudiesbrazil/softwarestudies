%function h=ihist(I,nbins)
% calculated histogram of a 2D object I, given nbins
% this function aims at substituting imhist when the object is not an uint#
function h=ihist(I,nbins)

I=double(I);
h=hist(reshape(I,1,size(I,1)*size(I,2)),0:nbins-1);

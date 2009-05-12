%Function to convert a color image into its intensity version
%For better visualization, use the command colormap(gray) after imagesc(.)
function gray=rgbToGray(immRGB)

[m,n,o]=size(immRGB);

R= reshape(immRGB(:,:,1),m,n);
G= reshape(immRGB(:,:,2),m,n);
B= reshape(immRGB(:,:,3),m,n);

gray = .30*R + .59*G + .11*B;

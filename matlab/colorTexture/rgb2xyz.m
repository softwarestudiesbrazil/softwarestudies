
function immXYZ=rgb2xyz(immRGB)


gamma=2.2;

immRGB=double(immRGB);
immRGB=immRGB/255;
immRGB=immRGB.^gamma;

% double sRGBXYZD65[3][3]={{0.4124, 0.3576,0.1805},
%                          {0.2126, 0.7152,0.0722},
%                          {0.0193, 0.1192,0.9505}};
% 
% double sRGBXYZD50[3][3]={{0.4361, 0.3851,0.1431},
%                          {0.2225, 0.7169,0.0606},
%                          {0.0139, 0.0971,0.7141}};



T= [0.412453 0.357580 0.180423; 0.212671 0.715160 0.072169; 0.019334 0.119193 0.950227];%d65, sRGB 
%T= [0.4361 0.3851 0.1431; 0.2225 0.7169 0.0606; 0.0139 0.0971 0.7141];%d50, sRGB

m = size(immRGB,1); n = size(immRGB,2);
XYZ = reshape(immRGB(:),m*n,3)*T';

immXYZ(:,:,1)= reshape(XYZ(:,1),m,n);
immXYZ(:,:,2)= reshape(XYZ(:,2),m,n);
immXYZ(:,:,3)= reshape(XYZ(:,3),m,n);


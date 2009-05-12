
 function immRGB=xyz2rgb(immXYZ)


gamma=2.2; (sRGB)
%gamma=1;
T= [0.412453 0.357580 0.180423; 0.212671 0.715160 0.072169; 0.019334 0.119193 0.950227];%d65 white
T=inv(T);

m = size(immXYZ,1); n = size(immXYZ,2);
RGB = reshape(immXYZ(:),m*n,3)*T';
R= reshape(RGB(:,1),m,n);
G = reshape(RGB(:,2),m,n);
B = reshape(RGB(:,3),m,n);


immRGB(:,:,1)=abs(R);
immRGB(:,:,2)=abs(G);
immRGB(:,:,3)=abs(B);
immRGB=immRGB.^(1./gamma);
immRGB=uint8(round(immRGB*255));


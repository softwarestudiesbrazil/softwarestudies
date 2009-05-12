function immLab=XYZ2Lab(immXYZ)

immXYZ=double(immXYZ);
X=immXYZ(:,:,1);
Y=immXYZ(:,:,2);
Z=immXYZ(:,:,3);

%d65 white
X0=.9505;
Y0=1.00;
Z0=1.0891;

q=Y/Y0;
q1=7.787*q+16/116;
[in]=find(q>0.008856);
q1([in])=q([in]).^(1/3);

p=X/X0;
p1=7.787*p+16/116;
[in]=find(p>0.008856);
p1([in])=p([in]).^(1/3);

r=Z/Z0;
r1=7.787*r+16/116;
[in]=(r>0.008856);
r1([in])=r([in]).^(1/3);
 

immLab(:,:,1)=116*q1-16;
immLab(:,:,2)=500*(p1-q1);
immLab(:,:,3)=200*(q1-r1);





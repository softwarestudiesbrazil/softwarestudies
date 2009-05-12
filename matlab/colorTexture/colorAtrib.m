%function feat=colorAtrib(I)
%input I = original color image (original means with no preprocessing)
%return feat = [mean, standard deviation, skewness, kurtosis, energy,
%entropy]
%Daniela Ushizima - danicyber@gmail.com

function RGBchannels=colorAtrib(I)

histR=zeros(1,256);   histG=zeros(1,256);  histB=zeros(1,256);

[m,n,d]=size(I);
%histL=zeros(1,256);   histA=zeros(1,256);  histB=zeros(1,256); 
for i=1:m
    for j=1:n        
        cor = double(reshape(I(i,j,:),1,3)); 
        r= cor(1)+1;    
        g = cor(2)+1;   
        b = cor(3)+1; 
        histR(r)=histR(r)+1;      histG(g)=histG(g)+1;    histB(b)=histB(b)+1;
    end    
end
%Normalization
histR=histR./sum(histR); histG=histG./sum(histG);  histB=histB./sum(histB);
histRGB = [histR' histG' histB'];
RGBchannels = [];

for i=1:3 %para R,G,B
    oneChannel=Moments(0:255,histRGB(:,i)); %m,s,sk,ku,ene,ent    
    RGBchannels=[RGBchannels oneChannel];
end
    
%------------------------------------------------    
% Function Moments
function result = Moments(canal,histCanal)%ref. Pratt, Digital Image processing pg.561

 mi=0; std=0; s=0; k=0; ee=0;  et=0;
  
 for i=1:length(canal);
   mi=mi+canal(i)*histCanal(i); 
 end;

 for i=1:length(canal);
   b=canal(i); 
   p=histCanal(i);
   std=std + (b-mi)^2 * p;
   s  = s  + (b-mi)^3 * p; %skewness
   k  = k  + (b-mi)^4 * p - 3; %curtose
   ee = ee + p^2;    %energia
   et = et - p * log1p(p);    %entropy
 end;
 
 if std == 0
     disp('Std==0')
     std=0;
     s=1;
     k=1;;
 else
     std=sqrt(std);
     s=s/power(std,3);
     k=k/power(std,4);
 end
 result = [mi std s k ee et];

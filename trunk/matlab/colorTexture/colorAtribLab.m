%function feat=colorAtrib(I)
%input I = original color image (original means with no preprocessing)
%return feat = [mean, standard deviation, skewness, kurtosis, energy, entropy]
%Daniela Ushizima - danicyber@gmail.com

%CIE "L*a*b*" (CIELAB) is the most complete color space specified by the International Commission on Illumination ("Commission Internationale d'Eclairage", hence its "CIE" initialism). It describes all the colors visible to the human eye and was created to serve as a device independent model to be used as a reference.
%The three coordinates of CIELAB represent the lightness of the color ("L*" = 0 yields black and "L*" = 100 indicates diffuse white; specular white may be higher), its position between red/magenta and green ("a*", negative values indicate green while positive values indicate magenta) and its position between yellow and blue ("b*", negative values indicate blue and positive values indicate yellow). The asterisk (*) after L, a and b are part of the full name, since they represent L*, a* and b*, to distinguish them from Hunter's L, a and b, described below.
%Source: http://dic.academic.ru/dic.nsf/enwiki/211833
%if you are not familiar with LAB, check the link bellow for a visual idea
%http://www.colorpro.com/info/tools/rgbcalc.htm 

function LABchannels=colorAtribLab(I)

[m,n,d]=size(I);
histL=zeros(1,256);   histA=zeros(1,256);  histB=zeros(1,256); %256 so the resolution is proportional to the colorAtribRGB calculation
xyz = rgb2xyz(I);
lab = xyz2Lab(xyz);
for i=1:m
    for j=1:n        
        cor = lab(i,j,:);
        l = map_l(cor(1))+1;    
        a = map_a(cor(2))+1;%this mapping of index is necessary since matlab accept only positive indices    
        b = map_b(cor(3))+1; 
        histL(l)=histL(l)+1;      histA(a)=histA(a)+1;    histB(b)=histB(b)+1;
    end
end

%Normalization
histL=histL./sum(histL); 
histA=histA./sum(histA);  
histB=histB./sum(histB);
histLAB = [histL' histA' histB'];
LABchannels = [];

for i=1:3 %para R,G,B
    oneChannel=Moments(0:255,histLAB(:,i)); %m,s,sk,ku,ene,ent    
    LABchannels=[LABchannels oneChannel];
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
   k  = k  + (b-mi)^4 * p - 3; %kurtosis
   ee = ee + p^2;    %energy
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
 
%------------------------------------------------    
% Function Map_* => L=[0,100]
%indn is an index out of the acceptable matlab ranges
function ml = map_l(indn)
rangel=100-0+1;
ml = round(indn*255/rangel) + 1;

%------------------------------------------------    
% Function Map_* => a=[-.86,0.98] 
%indn is an index out of the acceptable matlab ranges
function ml = map_a(indn)
amax=79; amin=-80;
rangea=amax-amin+1;
ml = round( (indn-amin)*255/(rangea)) + 1;

%------------------------------------------------    
% Function Map_* => b=[-1.07,0.94]
%indn is an index out of the acceptable matlab ranges
function ml = map_b(indn)
bmax=100; bmin=-59;
rangeb=bmax-bmin+1;
ml = round( (indn-bmin)*255/(rangeb)) + 1;

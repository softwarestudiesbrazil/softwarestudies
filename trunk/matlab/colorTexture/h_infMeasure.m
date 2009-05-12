% h_infmeasure.m
% calculates the information measures of correlation given a co-occurrence matrix, P
% also known as f12 and f13 (Haralick 73)

function [f12,f13] = diffEntropy(P)

[A,B] = size(P);

px = sum(P,2);
py = sum(P,1);

HXY = h_entropy(P);
HX = - sum(px.*log(px+eps));
HY = - sum(py.*log(py+eps));
HXY1=0;
HXY2=0;

for a = 1:A
   for b = 1:B
       HXY1 = HXY1 +  P(a,b)       * log2(px(a)*px(b)+eps); %eps is a matlab variable, an arbitrarily small positive constant    
       HXY2 = HXY2 + (px(a)*px(b)) * log2(px(a)*px(b)+eps); 
   end
end

HXY1=-HXY1;
HXY2=-HXY2;

f12 = (HXY - HXY1)/max(HX,HY);
f13 = ( 1 - exp(-2*(HXY2-HXY)) )^.5;

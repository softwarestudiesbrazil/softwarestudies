%function vfeat=getTextFeat(co)
%get a list of texture features from the cooccurrence matrix
function vfeat=getTextFeat(co)

f1 = h_energy(co); %f1 measure according to Haralick 73
f2 = h_contrst(co);%f2
f3 = h_idm(co);%f3
f4 = h_sumOfSquares(co);
f5 = h_corr(co);
%f6 =h_sumAverage(co);
%f7 =h_sumVariance(co);
%f8 =h_sumEntropy(co);
f9 = h_entropy(co);
%f10 = h_diffVar(co);
%f11 = h_diffEntropy(co);
[f12,f13] = h_infMeasure(co);


vfeat=[f1,f2,f3,f4,f5,f9,f12,f13];

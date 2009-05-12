% sumEntropy.m
% calculates the sum of entropy given a co-occurrence matrix, P
% also known as f8 (Haralick 73)

function [s] = sumEntropy(P)

Ng = size(P,1);
pxy=h_p_xplusy(P);

s = -sum( pxy.*log(pxy+eps) );   
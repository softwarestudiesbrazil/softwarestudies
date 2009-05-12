% diffEntropy.m
% calculates the difference of entropy given a co-occurrence matrix, P
% also known as f11 (Haralick 73)

function [s] = diffEntropy(P)

Ng = size(P,1);
pxy=h_p_xminusy(P);

s = -sum( pxy.*log(pxy+eps) );   
% sumVariance.m
% calculates the sum of variance given a co-occurrence matrix, P
% also known as f7 (Haralick 73)

function [s] = sumVariance(P)

Ng = size(P,1);
pxy=h_p_xplusy(P);
f8 = h_sumEntropy(P);
I=2:1:2*Ng;

I2 = (I-f8).^2;

s = sum( I2.*pxy );   
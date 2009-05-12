% sumAverage.m
% calculates the sum of average given a co-occurrence matrix, P
% also known as f6 (Haralick 73)

function [s] = sumAverage(P)

Ng = size(P,1);
pxy=h_p_xplusy(P);
I=2:1:2*Ng;

s = sum(I.*pxy);   
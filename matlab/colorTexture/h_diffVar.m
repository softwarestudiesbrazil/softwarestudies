% diffVar.m
% calculates the difference variance given a co-occurrence matrix, P
% also known as f10 (Haralick 73)

function [s] = diffVar(P)

Ng = size(P,1);
pxy=h_p_xminusy(P);

s = sum( ((Ng-1).^2).*pxy );   
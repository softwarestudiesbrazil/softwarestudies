% idm.m
% calculates the inverse difference moment given a co-occurrence matrix, P

function [idm] = idm(P)

[A,B] = size(P);

idm = 0;

for a = 1:A
   for b = 1:B
       idm = idm + ( P(a,b) / (1+ (a - b)^2) );               
   end
end
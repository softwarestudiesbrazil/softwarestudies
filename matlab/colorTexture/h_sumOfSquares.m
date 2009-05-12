% sumOfSquares.m
% calculates the sum of squares given a co-occurrence matrix, P
% also known as variance or f4 (Haralick 73)

function [s] = sumOfSquares(P)

[A,B] = size(P);

s = 0;

m=mean(mean(P));

for a = 1:A
   for b = 1:B
      s = s + (a-m)^ 2 * P(a,b);
   end
end
    
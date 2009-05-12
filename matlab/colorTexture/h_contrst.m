% contrst.m
% calculates the contrast given a co-occurrence matrix, P

function [cont] = contrst(P)

[A,B] = size(P);

cont = 0;

for a = 1:A
   for b = 1:B
      if P(a,b) ~= 0
         cont = cont + ((abs(a - b)) ^ 2) * P(a,b);
      end
   end
end
    
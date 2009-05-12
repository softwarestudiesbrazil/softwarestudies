% corr.m
% calculates the correlation given a co-occurrence matrix, P

function [c] = corr(P)

[A,B] = size(P);

% calculate the means mx and my
mx = 0;
my = 0;

for a = 1:A
   for b = 1:B
       if(P(a,b) ~= 0)
           mx = mx + a * P(a,b);
           my = my + b * P(a,b);
       end
   end
end

% calculate standard deviation sx and sy
sx = 0;
sy = 0;

for a = 1:A
   for b = 1:B
       if(P(a,b) ~= 0)
           sx = sx + ((a - mx) ^ 2) * P(a,b);
           sy = sy + ((b - my) ^ 2) * P(a,b);
       end
   end
end

% calculate the correlation from mx, my, sx, and sy
summ = 0;
m = mx * my;

for a = 1:A
   for b = 1:B
       if(P(a,b) ~= 0)
           summ = summ + (a * b * P(a,b));
       end
   end
end

c = (summ - m) / (sx * sy);    
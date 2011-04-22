function [output] = f_bvlc(I,n,d)
% f_bvlc Block variabtion of local correlation coefficients.
%
%   Input: I - grayscale image
%          n - number of spatial blocks
%          d - distance to calculate correlation
%   Remarks:
%     1. Ordering of spatial features is assigned left-to-right e.g.
%                1 | 2
%               -------
%                3 | 4 
%     2. Higher BVLC indicates higher degree of roughness.

% returns the name of the features when no argument is given.
if isempty(I)
    output.header = {};
    output.type = {};
    for i=1:n*n
        output.header{i} = sprintf('BVLC_%d_%dx%d_%d',d,n,n,i);
        output.type{i} = 'float';
    end
    return;
end

output = [];

% nxn
I = double(I);
w = size(I,2)/n;
h = size(I,1)/n;
idx = 1;
for i=1:n
    for j=1:n
        Ic = I(round((i-1)*h+1):round(i*h),...
            round((j-1)*w+1):round(j*w));
        Is = zeros(size(Ic,1)+2*d,size(Ic,2)+2*d);
        Is(1+d:end-d,1+d:end-d) = Ic;
        uc = mean(Ic);
        sc = std(Ic);
        idx2 = 1;
        rho = zeros(1,4);
        for k=[-d,d]
            for l=[-d,d]
                It = Is(1+d+k:d+size(Ic,1)+k,...
                    1+d+l:d+size(Ic,2)+l);
                ut = mean(It(:));
                st = std(It(:));
                x = Ic .* It;
                rho(idx2) = (sum(x(:))/(w*h) - uc*ut)/(sc*st);
                idx2 = idx2 + 1;
            end
        end
        output(idx) = max(rho) - min(rho);
        idx = idx + 1;
    end
end

end
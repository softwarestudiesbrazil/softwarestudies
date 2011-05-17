function [output] = f_bdip(I,n)
% f_bdip Block difference of inverse probabilities.
%
%   Input: I - grayscale image
%          n - number of spatial blocks
%   Remarks:
%     1. Ordering of spatial features is assigned left-to-right e.g.
%                1 | 2
%               -------
%                3 | 4 
%     2. The feature values has range from 0 to 1 where 0 corresponds to
%     no texture.
%


% returns the name of the features when no argument is given.
if isempty(I)
    output.header = {};
    output.type = {};
    for i=1:n*n
        output.header{i} = sprintf('BDIP_%dx%d_%d',n,n,i);
        output.type{i} = 'float';
    end
    return;
end

output = [];

% nxn
I = double(I);
k = 1;
w = size(I,2)/n;
h = size(I,1)/n;
for i=1:n
    for j=1:n
        Ic = I(round((i-1)*h+1):round(i*h),...
            round((j-1)*w+1):round(j*w));
        output(k) = ((w*h) - sum(Ic(:))/max(Ic(:)))/ (w*h);
        k = k + 1;
    end
end

end
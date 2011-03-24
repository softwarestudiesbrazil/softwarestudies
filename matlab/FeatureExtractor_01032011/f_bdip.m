function [output] = f_bdip(I,n)
% f_bdip Block difference of inverse probabilities
%   I = grayscale image
%   output = [nxn BDIP features]
%
% NOTE: feature value has range from 0 to 1 where 0 means no texture


% returns the name of the features when no argument is given.
if isempty(I)
    output = {};
    for i=1:n*n
        output{i} = sprintf('BDIP_%d_%d_%d',n,n,i);
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
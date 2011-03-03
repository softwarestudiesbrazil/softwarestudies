function [output] = f_sobel(I)
% f_sobel Amount of sobel edge
%   I = grayscale image
%   output = [sobel]

% returns the name of the features when no argument is given.
if nargin == 0
    output = {'EdgeAmountSobel'};
    return;
end

output = sum(sum(edge(I,'sobel')))/(size(I,1)*size(I,2));
 
end

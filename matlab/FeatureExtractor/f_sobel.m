function [output] = f_sobel(I)
% f_sobel Average energy of sobel filter per pixel
%
%   Input: I - grayscale image
%   

% returns the name of the features when no argument is given.
if nargin == 0
    output.header = {'Edge_Amount_Sobel'};
    output.type = {'float'};
    return;
end

J = edge(I,'sobel');
output = sum(J(:))/(size(I,1)*size(I,2));
 
end

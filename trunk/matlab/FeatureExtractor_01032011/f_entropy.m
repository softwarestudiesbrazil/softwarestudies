function [output] = f_entropy(I)
% f_entropy Entropy
%
%   Input: I - grayscale image
%

% returns the name of the features when no argument is given.
if nargin == 0
    output.header = {'Entropy'};
    output.type = {'float'};
    return;
end

output = entropy(I);
 
end

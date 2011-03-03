function [output] = f_entropy(I)
% f_entropy Entropy
%   I = grayscale image
%   output = [entropy]

% returns the name of the features when no argument is given.
if nargin == 0
    output = {'Entropy'};
    return;
end

output = entropy(I);
 
end

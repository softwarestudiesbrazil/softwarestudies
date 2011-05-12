function [output] = f_grayHist(I,n)
% f_grayHist n-bin grayscale histogram
%
%   Input: I - grayscale image
%          n - number of bins
%   Remarks: 
%     1. The output histogram is normalized so that the bin with maximum
%     frequency always has value of 1.0

% returns the name of the features when I is empty
if isempty(I)
    output.header = {};
    output.type = {};
    for i=1:n
        fname = ['GrayH_' num2str(n) '_' num2str(i)];
        output.header = [output.header fname];
        output.type = [output.type 'float'];
    end
    return;
end

% center of each bin
center = linspace(0,255,n+1);
center = (center(2:end) + center(1:end-1))/2;

y = double(I(:,:));
y = y(:);
output = hist(y,center);
output = output / max(output);

end

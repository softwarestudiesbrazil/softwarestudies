function [output] = f_hsvHist(I,n)
% f_hsvHist n-bin HSV histogram
%
%   Input: I - HSV image
%          n - number of bins
%   Remarks:
%     1. The output histogram is normalized so that the bin with maximum
%     frequency always has value of 1.0. The normalization is done across 
%     colors i.e. [HH SH VH]/max([HH SH VH])
%

% returns the name of the features when I is empty
if isempty(I)
    Cnames = {'H','S','V'};
    output.header = {};
    output.type = {};
    for j=1:length(Cnames)
        for i=1:n
            fname = [Cnames{j} 'H_' num2str(n) '_' num2str(i)];
            output.header = [output.header fname];
            output.type = [output.type 'float'];
        end
    end
    return;
end

if (ndims(I) == 3 && size(I,3) == 3)
    % center of each bin
    center = linspace(0,1.0,n+1);
    center = (center(2:end) + center(1:end-1))/2;
    
    % H
    y = double(I(:,:,1));
    y = y(:);
    HH = hist(y,center);
    
    % S
    y = double(I(:,:,2));
    y = y(:);
    SH = hist(y,center);
    
    % V
    y = double(I(:,:,3));
    y = y(:);
    VH = hist(y,center);
    
    Z = max([HH SH VH]);
    output = [HH SH VH]/Z;
else
    output = zeros(1,3*n);
end

end

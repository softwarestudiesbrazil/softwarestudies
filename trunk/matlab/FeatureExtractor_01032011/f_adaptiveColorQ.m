function [output] = f_adaptiveColorQ(I,n,k)
% f_adaptiveColorQ Adaptive color quantization
%
%   Input: I = RGB image
%          n = number of different colors to reduce to
%          k = number of colors to report
%   Remarks: 
%     1. When number of colors on the image is less than k, NaN is used
%        to indicate extra colors.
%     2. RGB has range [0,255]. HSV has range [0,1].
%

if nargin < 2
    % default n = 16
    n = 16;
end

if nargin < 3
    % default k = 2
    k = 2;
end

% return header when I is empty
if isempty(I)
    Cnames = {'ACQ_R','ACQ_G','ACQ_B','ACQ_H','ACQ_S','ACQ_V'};
    output.header = {};
    output.type = {};
    for i=1:k
        for j=1:length(Cnames)
            fname = [Cnames{j} '_' num2str(n) '_' num2str(i)];
            output.header = [output.header fname];
            output.type = [output.type 'float'];
        end
    end
    return;
end

if (ndims(I) == 3 && size(I,3) == 3)
    [idx_img,map] = rgb2ind(I, n, 'nodither');
    
    count = zeros(n,2);
    for i=1:n
        count(i,1) = i;
        count(i,2) = size(find(idx_img(:) == (i-1)),1);
    end
    
    count = sortrows(count,-2);
    
    % if number of colors is fewer than k
    if size(map,1) < k
        l = size(map,1);
        rgb = map(count(1:l,1),:);
        hsv = rgb2hsv(rgb);
        output = [rgb*255.0 hsv];
        output = [output;NaN(k-l,6)];
    else
        rgb = map(count(1:k,1),:);
        hsv = rgb2hsv(rgb);
        output = [rgb*255.0 hsv];
    end
    
    output = output';
    output = output(:)';
else
    output = NaN(1,6*k);
end

end

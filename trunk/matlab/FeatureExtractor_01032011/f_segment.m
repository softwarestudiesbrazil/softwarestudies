function [output] = f_segment(I)
% f_segment Partition image into segments of similar colors.
%   I = RGB image
%
% Ordering of spatial features:
%   1 | 2
%  -------
%   3 | 4 

% returns the name of the features when I is empty
if isempty(I)
    output = {'TOTLA_NUM_SEGMENTS','MEAN_AREA','MIN_AREA','MAX_AREA',...
        'MEDIAN_AREA'};
    for n=2:4
        for i=1:n*n
            output = [output sprintf('NUM_SEGMENTS_%d_%d_%d',n,n,i)];
        end
    end
    return;
end

% for grayscale images, we do preprocessing
if ndims(I) <= 2
    % perform contrast equalization
    I = adapthisteq(I);
    
    % thicken the edges
    se90 = strel('line', 2, 90);
    se0 = strel('line', 2, 0);
    I_eroded = imerode(I, [se90 se0]);
    
    % recontruct rgb image
    I = repmat(I_eroded,[1 1 3]);
end

% smooth the image a little
gaussianFilter = fspecial('gaussian', [3, 3], 5);
I = imfilter(I, gaussianFilter);
    
% reduce colors
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALWAYS reduce to 4 colors
%%%%%%%%%%%%%%%%%%%%%%%%%%%
d = 4;
[Iindx,map] = rgb2ind(I,d,'nodither');
k = 0;
L_combined = zeros(size(I,1),size(I,2));
for i=0:d-1
    L = (Iindx == i);
    % remove area smaller than 10 pixels
    L = bwareaopen(L,10);
    L = bwlabel(L);
    L_combined = L_combined + L + k*(L > 0);
    k = k + max(max(L));
end
L_combined = uint32(L_combined);

% generate rgb image
%Lrgb = label2rgb(L_combined);

% count area
areas = zeros(1,max(L_combined(:)));
for i=1:size(L_combined,1)
    for j=1:size(L_combined,2)
        if L_combined(i,j) > 0
            areas(L_combined(i,j)) = areas(L_combined(i,j))+1;
        end
    end
end

output = [sum(areas > 0),...
    mean(areas(areas > 0)),...
    min(areas(areas > 0)),...
    max(areas(areas > 0)),...
    median(areas(areas > 0))];
output = [output count_subimage(L_combined,2)];
output = [output count_subimage(L_combined,3)];
output = [output count_subimage(L_combined,4)];

end


function l = count_subimage(I,n)
w = size(I,2)/n;
h = size(I,1)/n;
idx = 1;
l = zeros(1,n*n);
for i=1:n
    for j=1:n
        Ic = I(round((i-1)*h+1):round(i*h),...
            round((j-1)*w+1):round(j*w));
        l(idx) = size(unique(Ic(:)),1);
        idx = idx + 1;
    end
end
    
end

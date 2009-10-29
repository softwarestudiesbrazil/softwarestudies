
function [output,header] = basicInfo(I,IPT)

% basicInfo extract basic information
% I = RGB or grayscale image
% IPT = true if IPT installed
% output = [entropy,
%           mean,
%           std,
%           edgeAmountSobel]

% by default, output values are zeros
output = [];
header = {};

% if I is rgb, convert to grayscale
if (ndims(I) == 3 && size(I,3) == 3)
    if (IPT)
        I = rgb2gray(I);
    else
        I = 0.2989*I(:,:,1) + 0.5870*I(:,:,2) + 0.1140*I(:,:,3);
    end
end

% convert to double for mean and std calculation
Id = double(I(:));
output(1,1) = mean(Id);
header(1,1) = cellstr('Mean');
output(1,2) = std(Id);
header(1,2) = cellstr('Std');

if (IPT)
    output(1,3) = entropy(I);
    header(1,3) = cellstr('Entropy');
end

% Sobel edge ratio
if (IPT)
    edgeAmountSobel = sum(sum(edge(I,'sobel')))/(size(I,1)*size(I,2));
    output(1,4) = edgeAmountSobel;
    header(1,4) = cellstr('Sobel');
end

end

function [output] = f_adaptiveColorQ(I,n,k)
% f_adaptiveColorQ Adaptive color quantization
%   I = RGB image
%   n = number of different colors
%   k = number of colors to report
%   output = [red_n_1,green_n_1,blue_n_1,hue_n_1,sat_n_1,value_n_1,
%             red_n_2,green_n_2,blue_n_2,hue_n_2,sat_n_2,value_n_2,...
%             red_n_k,green_n_k,blue_n_k,hue_n_k,sat_n_k,value_n_k]

if nargin < 2
    n = 16;
end

if nargin < 3
    k = 2;
end

% return header when I is empty
if isempty(I)
    Cnames = {'ACQ_R','ACQ_G','ACQ_B','ACQ_H','ACQ_S','ACQ_V'};
    output = {};
    for i=1:k
        for j=1:length(Cnames)
            fname = [Cnames{j} '_' num2str(n) '_' num2str(i)];
            output = [output fname];
        end
    end
    return;
end

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

end

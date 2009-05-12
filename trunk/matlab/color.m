
function T = color(imgFile,n,k)
% get top k color from n indexed color
% T(1) = R
% T(2) = G
% T(3) = B
% T(4) = percentage

if nargin < 2
    n = 16;
end

if nargin < 3
    k = n;
end

img = imread(imgFile);
[idx_img,map] = rgb2ind(img,n);

count = zeros(n,2);
for i=1:n
    count(i,1) = i;
    count(i,2) = size(find(idx_img(:) == (i-1)),1);
end

count = sortrows(count,-2);

s = sum(count(:,2));
T = [map(count(1:k,1),:)*255 count(1:k,2)*100/s];

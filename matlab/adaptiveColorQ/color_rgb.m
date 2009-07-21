
function T = color_rgb(imgFile,n,k,outputImg)

% get top k color from n indexed color
% T(:,1) = R
% T(:,2) = G
% T(:,3) = B
% T(:,4) = H
% T(:,5) = S
% T(:,6) = V
% T(:,7) = percentage

if nargin < 2
    n = 16;
end

if nargin < 3
    k = 1;
end

if nargin < 4
    outputImg = 0;
end

if k > n 
    k = n;
end

img = imread(imgFile);

if (ndims(img) == 3 && size(img,3) == 3)
    
    [idx_img,map] = rgb2ind(img,n,'nodither');
    
    if outputImg > 0
        imwrite(idx_img,map,[imgFile '_' num2str(n) '_' num2str(k) '.out.jpg'],'jpg');
    end
    
    count = zeros(n,2);
    for i=1:n
        count(i,1) = i;
        count(i,2) = size(find(idx_img(:) == (i-1)),1);
    end
    
    count = sortrows(count,-2);
    s = sum(count(:,2));
    if size(map,1) < k
        l = size(map,1);
        rgb = map(count(1:l,1),:);
        hsv = rgb2hsv(rgb);
        T = [rgb*255 hsv count(1:l,2)*100/s];
        filler = [NaN(k-l,6) zeros(k-l,1)];
        T = [T;filler];
    else
        rgb = map(count(1:k,1),:);
        hsv = rgb2hsv(rgb);
        T = [rgb*255 hsv count(1:k,2)*100/s];
    end
    
else
    
    % input is grayscale
    T = zeros(k,4);
    
end
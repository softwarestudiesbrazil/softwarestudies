
function [c1,c2] = vis_color_rgb(inp,n)

I1 = imread(inp);
[I2 M2] = rgb2ind(I1,n,'nodither');

T = color_rgb(inp,n,2);
I3 = zeros(20,20,3);
I3(:,:,1) = repmat(T(1,1),20,20);
I3(:,:,2) = repmat(T(1,2),20,20);
I3(:,:,3) = repmat(T(1,3),20,20);
I3 = uint8(I3);
I4 = zeros(20,20,3);
I4(:,:,1) = repmat(T(2,1),20,20);
I4(:,:,2) = repmat(T(2,2),20,20);
I4(:,:,3) = repmat(T(2,3),20,20);
I4 = uint8(I4);

c1 = T(1,:);
c2 = T(2,:);

figure;
subplot(2,2,1); subimage(I1); title('original');
subplot(2,2,2); subimage(I2,M2); title('quantized');
subplot(2,2,3); subimage(I3); title('color1');
subplot(2,2,4); subimage(I4); title('color2');


end

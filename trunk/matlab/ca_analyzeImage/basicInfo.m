
function [output,header] = basicInfo(I)

% basicInfo extract basic information
% I = RGB or grayscale image
% output = [entropy, 
%           mean, 
%           std,
%           edgeAmountSobel]

  % by default, output values are zeros
  output = zeros(1,4);
  header = cell(1,4);
  
  % if I is rgb, convert to grayscale
  if (ndims(I) == 3 && size(I,3) == 3)
    %I = rgb2gray(I);
    I = 0.2989*I(:,:,1) + 0.5870*I(:,:,2) + 0.1140*I(:,:,3);
  end 
 
  output(1,1) = entropy(I);
  header(1,1) = cellstr('Entropy');
  
  % convert to double for mean and std calculation
  Id = double(I(:));
  output(1,2) = mean(Id);
  header(1,2) = cellstr('Mean');
  output(1,3) = std(Id);
  header(1,3) = cellstr('Std');
  
  % Sobel edge ratio 
  edgeAmountSobel = sum(sum(edge(I,'sobel')))/(size(I,1)*size(I,2));
  output(1,4) = edgeAmountSobel;
  header(1,4) = cellstr('Sobel');
  
end
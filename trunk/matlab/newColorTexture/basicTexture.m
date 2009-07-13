
function [output] = basicTexture(I,D)

% basicTexture extract basic texture information
% I = RGB or grayscale image
% D = distance for GLCM
% output = [entropy, contrast, correlation,
%           energy, homogeneity, mean, std, edgeAmountSobel]

  % by default, vaules are zeros
  output = zeros(1,8);
  
  % if I is rgb, convert to grayscale
  if (ndims(I) == 3 && size(I,3) == 3)
    I = rgb2gray(I);
  end 
  
  output(1,1) = entropy(I);
  
  offsets = [0 D; -D D; -D 0; -D -D];
  GLCMs = graycomatrix(I,'Offset',offsets);
  stats = graycoprops(GLCMs,{'Contrast',...
      'Correlation',...
      'Energy',...
      'Homogeneity'});
  
  output(1,2) = mean(stats.Contrast);
  output(1,3) = mean(stats.Correlation);
  output(1,4) = mean(stats.Energy);
  output(1,5) = mean(stats.Homogeneity);

  Id = double(I(:));
  output(1,6) = mean(Id);
  output(1,7) = std(Id);
  
  edgeAmountSobel = sum(sum(edge(I,'sobel')))/(size(I,1)*size(I,2));
  output(1,8) = edgeAmountSobel;
  
end
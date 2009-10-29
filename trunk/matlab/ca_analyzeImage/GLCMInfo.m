
function [output,header] = GLCMInfo(I,D)

% GLCMInfo extract GLCM information
% I = RGB or grayscale image
% D = distance for GLCM
% output = [contrast, 
%           correlation,
%           energy, 
%           homogeneity]

  % by default, output values are zeros
  output = zeros(1,4);
  header = cell(1,4);
 
  % if I is rgb, convert to grayscale
  if (ndims(I) == 3 && size(I,3) == 3)
    I = rgb2gray(I);
  end 
  
  % compute GLCM and its stats
  offsets = [0 D; -D D; -D 0; -D -D];
  GLCMs = graycomatrix(I,'Offset',offsets);
  stats = graycoprops(GLCMs,{'Contrast',...
                             'Correlation',...
                             'Energy',...
                             'Homogeneity'});
  
  output(1,1) = mean(stats.Contrast);
  header(1,1) = cellstr(['Contrast_' num2str(D)]);
  output(1,2) = mean(stats.Correlation);
  header(1,2) = cellstr(['Correlation_' num2str(D)]);
  output(1,3) = mean(stats.Energy);
  header(1,3) = cellstr(['Energy_' num2str(D)]);
  output(1,4) = mean(stats.Homogeneity);
  header(1,4) = cellstr(['Homogeneity_' num2str(D)]);

end
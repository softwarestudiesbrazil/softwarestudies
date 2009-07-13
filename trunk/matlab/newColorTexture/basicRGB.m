
function [output] = basicRGB(I)

% basicRGB extract low level feature from RGB
%   I = RGB image
%   output = [mean, median, std, skewness, kurtosis]

  % by default, vaules are zeros
  output = zeros(1,5*3);
  
  if (ndims(I) == 3 && size(I,3) == 3)  
    % for each channel
    for j=1:3
      C = double(I(:,:,j));
      C = C(:);
      output(1,(j-1)*5+1) = mean(C);
      output(1,(j-1)*5+2) = median(C);
      output(1,(j-1)*5+3) = std(C);
      output(1,(j-1)*5+4) = skewness(C);
      output(1,(j-1)*5+5) = kurtosis(C);
    end
  end        
  
end
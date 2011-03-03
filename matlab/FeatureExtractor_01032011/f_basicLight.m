function [output] = f_basicLight(I)
% f_basicLight Basic statistics from grayscale
%   I = grayscale image
%   output = [mean, median, std, skewness, kurtosis, min, max]

% returns the name of the features when no argument is given.
if nargin == 0
    output = {'Brightness_Mean','Brightness_Median','Brightness_Std',...
        'Brightness_Skewness','Brightness_Kurtosis',...
        'Brightness_Min','Brightness_Max'};
    return;
end

x = double(I(:,:));
x = x(:);
output = [mean(x) median(x) std(x) skewness(x) kurtosis(x) min(x) max(x)];

end

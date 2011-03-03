function [output] = f_basicHSV(I)
% f_basicHSV Basic statistics from HSV
%   I = HSV image
%   output = [mean, median, std, skewness, kurtosis, min, max]

% returns the name of the features when no argument is given.
if nargin == 0
    Cnames = {'Hue','Sat','Value'};
    Cfeatures = {'Mean','Median','Std','Skewness','Kurtosis','Min','Max'};
    output = {};
    for i=1:length(Cnames)
        for j=1:length(Cfeatures)
            fname = [Cnames{i} '_' Cfeatures{j}];
            output = [output fname];
        end
    end
    return;
end

% by default, vaules are zeros
output = zeros(1, 7*3);

% for each channel
for j=1:3
    C = double(I(:,:,j));
    C = C(:);
    output((j-1)*7+1) = mean(C);
    output((j-1)*7+2) = median(C);
    output((j-1)*7+3) = std(C);
    output((j-1)*7+4) = skewness(C);
    output((j-1)*7+5) = kurtosis(C);
    output((j-1)*7+6) = min(C);
    output((j-1)*7+7) = max(C);
end

end

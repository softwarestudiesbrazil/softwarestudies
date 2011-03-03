function [output] = f_glcm(I,D)
% f_glcm GLCM information
%   I = grayscale image
%   D = distance for GLCM
%   output = [contrast, correlation, energy, homogeneity]

% returns the name of the features when I is empty.
if isempty(I)
    output = {['Contrast_' num2str(D)], ['Correlation_' num2str(D)],...
        ['Energy_' num2str(D)], ['Homogeneity_' num2str(D)]};
    return;
end

% compute GLCM and its stats
offsets = [0 D; -D D; -D 0; -D -D];
GLCMs = graycomatrix(I,'Offset',offsets);
stats = graycoprops(GLCMs,{'Contrast','Correlation',...
    'Energy','Homogeneity'});

output = [mean(stats.Contrast) mean(stats.Correlation) ...
    mean(stats.Energy) mean(stats.Homogeneity)];

end
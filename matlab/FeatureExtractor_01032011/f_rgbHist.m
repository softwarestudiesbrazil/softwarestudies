function [output] = f_rgbHist(I,n)
% f_rgbHist n-bin histogram
%   I = RGB image
%   output = [RH_n_1, RH_n_2, ..., RH_n_n,...
%             GH_n_1, GH_n_2, ..., GH_n_n,...
%             BH_n_1, BH_n_2, ..., BH_n_n]
% NOTE: output histogram is normalized so that the bin with maximum
%  frequency always has value of 1.0. The normalization is done across
%  colors i.e. [RH GH BH]/max([RH GH BH])

% returns the name of the features when I is empty
if isempty(I)
    Cnames = {'R','G','B'};
    output = {};
    for j=1:length(Cnames)
        for i=1:n
            fname = [Cnames{j} 'H_' num2str(n) '_' num2str(i)];
            output = [output fname];
        end
    end
    return;
end

% center of each bin
center = linspace(0,255,n+1);
center = (center(2:end) + center(1:end-1))/2;

% R
y = double(I(:,:,1));
y = y(:);
RH = hist(y,center);

% G
y = double(I(:,:,2));
y = y(:);
GH = hist(y,center);

% B
y = double(I(:,:,3));
y = y(:);
BH = hist(y,center);

Z = max([RH GH BH]);
output = [RH GH BH]/Z;

end

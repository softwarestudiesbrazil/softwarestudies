function [output,outImg] = f_gabor(I)
% f_gabor Gabor features
%   I = grayscale image
%   output = [Gabor feature vecter]
%   outImg = [Gabor filtered images]
% NOTE: When the image is too small for the filter size, NaN is returned.

lambda = 5; % >= 2
theta = [0 pi/4 pi/2 3*pi/4];
numScales = 4;
gamma = 0.5;

% returns the name of the features when no argument is given.
if nargin == 0
    output = {};
    k=1;
    for i=1:numScales
        for j=1:length(theta)
            output{k} = ['Gabor_' num2str(i) '_' ...
				  num2str(180*theta(j)/pi)];
            k=k+1;
        end
    end
    return;
end

output = [];
outImg = {};

% precompute gabor filters
n = length(theta);
gb = cell(1,n);
for i=1:n
    gb{i} = gabor_fn(lambda,gamma,theta(i),0) + ...
        1i*gabor_fn(lambda,gamma,theta(i),pi/2);
end

% operate on different sizes exponentially smaller
k=1;
for i=1:numScales
    for j=1:length(theta)
        if (~isempty(I) && ...
                size(I,1) > size(gb{j},1) && ...
                size(I,2) > size(gb{j},2))
            Iout = abs(conv2(double(I),gb{j},'same'));
            outImg{k} = Iout;
            output(k) = sum(Iout(:))/(size(I,1)*size(I,2));
        else
            outImg{k} = [];
            output(k) = NaN;
        end
        k = k + 1;
    end
    % only downsize if current size is larger than 2x2
    if (size(I,1) > 2 && size(I,2) > 2)
        I = imresize(I, 0.5);
    else
        I = [];
    end
end

end

function gb=gabor_fn(lambda,gamma,theta,psi)
% Adapted from 
% http://matlabserver.cs.rug.nl/edgedetectionweb/web/edgedetection_params.html

bandwidth = 1.0;
sigma = lambda/pi*sqrt(log(2)/2)*(2^bandwidth+1)/(2^bandwidth-1);
sigma_x = sigma;
sigma_y = sigma/gamma;

% get filter size from sigma
n = 3;
max_x = floor(n*max(sigma_x,sigma_y));
max_y = max_x; % square filter
min_x = -max_x;
min_y = -max_y;
[x,y] = meshgrid(min_x:1:max_x,min_y:max_y);

xp = x*cos(theta) + y*sin(theta);
yp = -x*sin(theta) + y*cos(theta);
gb = exp(-0.5*(xp.^2/sigma_x^2+yp.^2/sigma_y^2)).*cos(2*pi*xp/lambda+psi);

end

function [output,outImg] = f_gabor(I)
% f_gabor Gabor features
%   I = grayscale image
%   output = [Gabor feature vecter]
%   outImg = [Gabor filtered images]

lambda_all = [5,10,15,20]; % >= 2
theta_all = [0 pi/4 pi/2 3*pi/4];
gamma = 0.5;

% returns the name of the features when no argument is given.
if nargin == 0
    output = {};
    k=1;
    for i=1:length(lambda_all)
        for j=1:length(theta_all)
            output{k} = ['Gabor_' num2str(lambda_all(i)) '_' num2str(theta_all(j))];
            k=k+1;
        end
    end
    return;
end

output = [];
outImg = [];
k=1;
for i=1:length(lambda_all)
    for j=1:length(theta_all)
        lambda = lambda_all(i);
        theta = theta_all(j);
        gb = gabor_fn(lambda,gamma,theta,0) +...
            1i*gabor_fn(lambda,gamma,theta,pi/2);
        Iout = abs(conv2(double(I),gb,'same'));
        outImg(:,:,k) = Iout;
        output(k) = sum(Iout(:))/(size(I,1)*size(I,2));
        k = k + 1;
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

function FeatureExtractor(input_dir, prefix)
% FeatureExtractor Visual features from jpeg files in a directory
%  Author: Sunsern Cheamanunkul 

if nargin < 2
    prefix = '';
else
    prefix = [prefix '_'];
end

if ~exist(input_dir,'dir')
    fprintf('Error: Input directory does not exist!\n');
    return;
end

%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%
supported_extension = '*.jpg';
light_file   = 'light.txt';
rgb_file     = 'rgb.txt';
hsv_file     = 'hsv.txt';
texture_file = 'texture.txt';

light_fn = fullfile(input_dir,[prefix light_file]);
rgb_fn = fullfile(input_dir,[prefix rgb_file]);
hsv_fn = fullfile(input_dir,[prefix hsv_file]);
texture_fn = fullfile(input_dir,[prefix texture_file]);

fprintf(['Input directory: ' input_dir '\n']);
fprintf(['Light features -> ' light_fn '\n']);
fprintf(['RGB features -> ' rgb_fn '\n']);
fprintf(['HSV features -> ' hsv_fn '\n']);
fprintf(['Texture features -> ' texture_fn '\n']);
fprintf('\n');

filelist = dir(fullfile(input_dir,supported_extension));
nimages = length(filelist);
lightf = fopen(light_fn,'w');
rgbf = fopen(rgb_fn,'w');
hsvf = fopen(hsv_fn,'w');
texturef = fopen(texture_fn,'w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print header and data type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = [f_basicLight()...
    f_grayHist([],8)...
    f_grayHist([],32)];
writeHeader(lightf, h);
fprintf('%d Light features\n',length(h));

h = [f_basicRGB()...
    f_adaptiveColorQ([],16,2)...
    f_rgbHist([],4)...
    f_rgbHist([],8)];
writeHeader(rgbf, h);
fprintf('%d RGB features\n',length(h));

h = [f_basicHSV()...
    f_hsvHist([],4)...
    f_hsvHist([],8)];
writeHeader(hsvf, h);
fprintf('%d HSV features\n',length(h));

h = [f_glcm([],1)...
     f_glcm([],2)...
     f_glcm([],4)...
     f_glcm([],8)...
     f_sobel()...
     f_entropy()];
writeHeader(texturef, h);
fprintf('%d Texture features\n',length(h));
fprintf('\n');

%%%%%%%%%%%%%%%%
% Process images 
%%%%%%%%%%%%%%%%
for i=1:nimages
    fprintf([filelist(i).name '\n']);
    
    % read image from file
    I = imread([input_dir '/' filelist(i).name]);
    
    if (ndims(I) == 3 && size(I,3) == 3)
        I_gray = rgb2gray(I);
    else
        I_gray = I;
    end
    
    % Light features
    fprintf('\t-Light...');
    tstart = tic;
    v = [f_basicLight(I_gray)... % Basic brightness info
        f_grayHist(I_gray,8)...  % 8-bin histogram
        f_grayHist(I_gray,32)];  % 32-bin histogram
    writeToFile(lightf, filelist(i).name, v);
    fprintf('DONE(%.2fs)\n',toc(tstart));
    
    % RGB features (color only)
    fprintf('\t-RGB...');
    if (ndims(I) == 3 && size(I,3) == 3)
        tstart = tic;
        v = [f_basicRGB(I)...           % Basic RGB info
            f_adaptiveColorQ(I,16,2)... % 2 most dominant colors
            f_rgbHist(I,4)...           % 4-bin histogram
            f_rgbHist(I,8)];            % 8-bin histogram
        writeToFile(rgbf, filelist(i).name, v);
        fprintf('DONE(%.2fs)\n',toc(tstart));
    else
        % not colored image
        fprintf('SKIPPED\n');
    end
    
    % HSV features (color only)
    fprintf('\t-HSV...');
    if (ndims(I) == 3 && size(I,3) == 3)
        I_hsv = rgb2hsv(I);
        tstart = tic;
        v = [f_basicHSV(I_hsv)... % Basic HSV info
            f_hsvHist(I_hsv,4)... % 4-bin histogram
            f_hsvHist(I_hsv,8)];  % 8-bin histogram
        writeToFile(hsvf, filelist(i).name, v);
        fprintf('DONE(%.2fs)\n',toc(tstart));
    else
        % not colored image
        fprintf('SKIPPED\n');
    end
    
    % Texture features
    fprintf('\t-Texture...');
    tstart = tic;
    v = [f_glcm(I_gray,1)... % GLCM with D = 1
        f_glcm(I_gray,2)...  % GLCM with D = 2
        f_glcm(I_gray,4)...  % GLCM with D = 4
        f_glcm(I_gray,8)...  % GLCM with D = 8
        f_sobel(I_gray)...   % Sobel edge
        f_entropy(I_gray)];  % Entropy
    writeToFile(texturef, filelist(i).name, v);
    fprintf('DONE(%.2fs)\n',toc(tstart));
end

fclose(lightf);
fclose(rgbf);
fclose(hsvf);
fclose(texturef);

end

function writeHeader(f, h)
    fprintf(f,'filename');
    fprintf(f,',%s',h{:});
    fprintf(f,'\n');
    fprintf(f,'string');
    for i=1:length(h)
        fprintf(f,',float');
    end
    fprintf(f,'\n');
end

function writeToFile(f, iname, v)
    fprintf(f,'%s',iname);
    fprintf(f,',%f',v(:));
    fprintf(f,'\n');
end

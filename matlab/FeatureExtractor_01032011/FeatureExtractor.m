function FeatureExtractor(input_location, prefix, options)
% FEATUREEXTRACTOR Extract visual features from jpeg files.
%     FeatureExtractor(input_location, prefix, options) -
%      input_location: path to images or a file containing paths to images.
%      prefix: prefix of the output files
%      options: 
%        '-r' Also process files in sub-directories
%
%  Author: Sunsern Cheamanunkul 

if nargin < 2
    prefix = '';
else
    prefix = [prefix '_'];
end

if nargin > 2 && strcmp(options,'-r')
    recursion = true;
else
    recursion = false;
end
 
%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%
supported_extension = '*.jpg';
light_file   = 'light.txt';
rgb_file     = 'rgb.txt';
hsv_file     = 'hsv.txt';
texture_file = 'texture.txt';
gabor_file   = 'gabor.txt';
spatial_file = 'spatial.txt';
segment_file = 'segment.txt';

light_fn = fullfile([prefix light_file]);
rgb_fn = fullfile([prefix rgb_file]);
hsv_fn = fullfile([prefix hsv_file]);
texture_fn = fullfile([prefix texture_file]);
gabor_fn = fullfile([prefix gabor_file]);
spatial_fn = fullfile([prefix spatial_file]);
segment_fn = fullfile([prefix segment_file]);

if exist(input_location,'dir')
    filelist = getFilelistFromDir(input_location,...
        supported_extension, recursion);
elseif exist(input_location,'file')
    filelist = getFilelistFromFile(input_location);
else
    fprintf(['Input Error. Input must be a directory containing jpegs '... 
        'or a file containing paths to images.\n']);
    return;
end

fprintf(['Input directory: ' input_location '\n']);
fprintf(['Light features -> ' light_fn '\n']);
fprintf(['RGB features -> ' rgb_fn '\n']);
fprintf(['HSV features -> ' hsv_fn '\n']);
fprintf(['Texture features -> ' texture_fn '\n']);
fprintf(['Gabor features -> ' gabor_fn '\n']);
fprintf(['Spatial features -> ' spatial_fn '\n']);
fprintf(['Segment features -> ' segment_fn '\n']);
fprintf('\n');

nimages = length(filelist);
lightf = fopen(light_fn,'w');
rgbf = fopen(rgb_fn,'w');
hsvf = fopen(hsv_fn,'w');
texturef = fopen(texture_fn,'w');
gaborf = fopen(gabor_fn,'w');
spatialf = fopen(spatial_fn,'w');
segmentf = fopen(segment_fn,'w');

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

h = f_gabor();
writeHeader(gaborf, h);
fprintf('%d Gabor features\n',length(h));

h = [f_bdip([],2)...
     f_bdip([],3)...
     f_bdip([],4)...
     f_bvlc([],2,1)...
     f_bvlc([],3,1)...
     f_bvlc([],4,1)];
writeHeader(spatialf, h);
fprintf('%d Spatial features\n',length(h));

h = f_segment([]);
writeHeader(segmentf, h);
fprintf('%d Segment features\n',length(h));

fprintf('\n');

%%%%%%%%%%%%%%%%
% Process images 
%%%%%%%%%%%%%%%%
for i=1:nimages
    fprintf([filelist(i).name '\n']);
    
    % read image from file
    if ~exist(filelist(i).name,'file')
        continue;
    end
    I = imread(filelist(i).name);
    
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
    
    % Gabor features
    fprintf('\t-Gabor...');
    tstart = tic;
    v = f_gabor(I_gray); % Gabor features
    writeToFile(gaborf, filelist(i).name, v);
    fprintf('DONE(%.2fs)\n',toc(tstart));

    % Segment features
    fprintf('\t-Segment...');
    tstart = tic;
    v = f_segment(I); % Segment features
    writeToFile(segmentf, filelist(i).name, v);
    fprintf('DONE(%.2fs)\n',toc(tstart));
    
    % Spatial features
    fprintf('\t-Spatial...');
    tstart = tic;
    v = [f_bdip(I_gray,2)... % 2x2 BDIP features
         f_bdip(I_gray,3)... % 3x3 BDIP features
         f_bdip(I_gray,4)... % 4x4 BDIP features
         f_bvlc(I_gray,2,1)... % 2x2 BCLV D=1 
         f_bvlc(I_gray,3,1)... % 3x3 BCLV D=1 
         f_bvlc(I_gray,4,1)];  % 4x4 BCLV D=1  
    writeToFile(spatialf, filelist(i).name, v);
    fprintf('DONE(%.2fs)\n',toc(tstart));
    
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
fclose(gaborf);
fclose(spatialf);
fclose(segmentf);

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

function filelist = getFilelistFromFile(f)
filelist = struct('name',{},'isdir',{});
fin = fopen(f,'r');
i = 1;
tline = deblank(fgets(fin));
while ischar(tline)
    if ~isempty(tline)
        filelist(i).name = tline;
        filelist(i).isdir = false;
        i = i + 1;
    end
    tline = deblank(fgets(fin));
end
fclose(fin);
end

function filelist = getFilelistFromDir(d,ext,recursion)
if ~recursion
    % no recursion
    filelist = dir(fullfile(d,ext));
    % insert d in front of filenames
    for j=1:length(filelist)
        filelist(j).name = fullfile(d,filelist(j).name);
    end
else
    filelist = dir(fullfile(d,ext));
    % insert d in front of filenames
    for j=1:length(filelist)
        filelist(j).name = fullfile(d,filelist(j).name);
    end
    allfile = dir(d);
    for i=1:length(allfile)
        if allfile(i).isdir && ...
                isempty(regexp(allfile(i).name,'^[.]', 'once'))
            filelist = [filelist; ...
                getFilelistFromDir(fullfile(d,allfile(i).name),...
                ext,recursion)];
        end
    end
end
end




function runPCA(result_path, prefix)
%RUNPCA Summary of this function goes here
%   Detailed explanation goes here

data_gabor = readResultFile(fullfile(result_path,[prefix '_gabor.txt']));
data_hsv = readResultFile(fullfile(result_path,[prefix '_hsv.txt']));
data_rgb = readResultFile(fullfile(result_path,[prefix '_rgb.txt']));
data_light = readResultFile(fullfile(result_path,[prefix '_light.txt']));
data_segment = readResultFile(fullfile(result_path,[prefix '_segment.txt']));
data_spatial = readResultFile(fullfile(result_path,[prefix '_spatial.txt']));
data_texture = readResultFile(fullfile(result_path,[prefix '_texture.txt']));

%%%%%%%%%%%%%%%
% all features
%%%%%%%%%%%%%%%
header = [data_gabor.header data_hsv.header data_rgb.header...
    data_light.header data_segment.header data_spatial.header...
    data_texture.header];
data = [data_gabor.value data_hsv.value data_rgb.value...
    data_light.value data_segment.value data_spatial.value...
    data_texture.value];

% remove NaN and Inf
data(isnan(data)) = 0;
data(isinf(data)) = 0;

[coeff, score] = princomp(data);
writeScore([prefix '_pca_all.score.txt'],data_gabor.filename, score);
writeCoeff([prefix '_pca_all.coeff.txt'],header, coeff);

%%%%%%%%%%%%%%%%%%
% composition
%%%%%%%%%%%%%%%%%%
header = [data_segment.header data_spatial.header];
data = [data_segment.value data_spatial.value];

% remove NaN and Inf
data(isnan(data)) = 0;
data(isinf(data)) = 0;

[coeff, score] = princomp(data);
writeScore([prefix '_pca_composition.score.txt'],data_gabor.filename, score);
writeCoeff([prefix '_pca_composition.coeff.txt'],header, coeff);

%%%%%%%%%%%%%%%
% color
%%%%%%%%%%%%%%%
header = [data_hsv.header data_rgb.header data_light.header];
data = [data_hsv.value data_rgb.value data_light.value];

% remove NaN and Inf
data(isnan(data)) = 0;
data(isinf(data)) = 0;

[coeff, score] = princomp(data);
writeScore([prefix '_pca_color.score.txt'],data_gabor.filename, score);
writeCoeff([prefix '_pca_color.coeff.txt'],header, coeff);

%%%%%%%%%%%%%%%
% texture
%%%%%%%%%%%%%%%
header = [data_texture.header];
data = [data_texture.value];

% remove NaN and Inf
data(isnan(data)) = 0;
data(isinf(data)) = 0;

[coeff, score] = princomp(data);
writeScore([prefix '_pca_texture.score.txt'],data_gabor.filename, score);
writeCoeff([prefix '_pca_texture.coeff.txt'],header, coeff);

%%%%%%%%%%%%%%%
% orientation
%%%%%%%%%%%%%%%
header = [data_gabor.header];
data = [data_gabor.value];

% remove NaN and Inf
data(isnan(data)) = 0;
data(isinf(data)) = 0;

[coeff, score] = princomp(data);
writeScore([prefix '_pca_orientation.score.txt'],data_gabor.filename, score);
writeCoeff([prefix '_pca_orientation.coeff.txt'],header, coeff);


end

function writeScore(outputFile, filename, score)
    fid = fopen(outputFile,'w');
    fprintf(fid,'filename,pca1,pca2,pca3\n');
    for i=1:length(filename)
        fprintf(fid,'%s,%f,%f,%f\n',filename{i},score(i,1:3));
    end
    fclose(fid);
end

function writeCoeff(outputFile, header,coeff)
    fid = fopen(outputFile,'w');
    fprintf(fid,'feature_name,component1,component2,component3\n');
    for i=1:length(header)
        fprintf(fid,'%s,%f,%f,%f\n',header{i},coeff(i,1:3));
    end
    fclose(fid);
end


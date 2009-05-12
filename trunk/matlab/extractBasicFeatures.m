function extractBasicFeatures(imagePath, outputPath)
% extractBasicFeatures extracts basic feature values from many channels
%      
%  This function will extract the following features:
%    Min = minimum
%    Max = maximum
%    Mean = mean
%    Std = standard deviation
%    EdgeAmountSobel = sum of output from sobel edge detector divided
%                      by the size of the image. NOTE Only for R,G,B and
%                      grey channel
%    EdgeAmountCanny = sum of output from canny edge detector divided
%                      by the size of the image. NOTE Only for R,G,B and
%                      grey channel
%
%  This works on the following channels simultaneouly:
%    Hue
%    Saturation
%    Value
%    Red
%    Green
%    Blue
%    Gray
%    BW
%
% Synopsis:
%    extractBasicFeatures(imagePath, outputPath)
%
% Input:
%    imagePath = path to input image to extract features
%    outputPath = path to output file
% 

rgb = imread(imagePath);
r = rgb(:,:,1); % red
g = rgb(:,:,2); % green
b = rgb(:,:,3); % blue

hsv = rgb2hsv(rgb);
h = hsv(:,:,1); % hue
s = hsv(:,:,2); % saturation
v = hsv(:,:,3); % value

gray = rgb2gray(rgb);
bw = im2bw(rgb);

% open up the file
fid = fopen(outputPath,'wt');

fprintf(fid,'--- channel:hue ---\n');
processMinMaxMean(fid,h);
fprintf(fid,'--- channel:saturation ---\n');
processMinMaxMean(fid,s);
fprintf(fid,'--- channel:value ---\n');
processMinMaxMean(fid,v);
fprintf(fid,'--- channel:red ---\n');
processMinMaxMean(fid,r);
processEdge(fid,r);
fprintf(fid,'--- channel:green ---\n');
processMinMaxMean(fid,g);
processEdge(fid,g);
fprintf(fid,'--- channel:blue ---\n');
processMinMaxMean(fid,b);
processEdge(fid,b);
fprintf(fid,'--- channel:gray ---\n');
processMinMaxMean(fid,gray);
processEdge(fid,gray);
fprintf(fid,'--- channel:bw ---\n');
processMinMaxMean(fid,bw);

% close the file
fclose(fid);

end


function processMinMaxMean(fid, x)
    fprintf(fid,'Min=%6.2f\n',min(min(x)));
    fprintf(fid,'Max=%6.2f\n',max(max(x)));
    fprintf(fid,'Mean=%6.2f\n',mean2(x));
    fprintf(fid,'Std=%6.2f\n',std2(x));
end

function processEdge(fid, x)
    edgeAmountSobel = sum(sum(edge(x,'sobel')))/(size(x,1)*size(x,2));
    edgeAmountCanny = sum(sum(edge(x,'canny')))/(size(x,1)*size(x,2));
    
    fprintf(fid,'EdgeAmountSobel=%6.2f\n', edgeAmountSobel);
    fprintf(fid,'EdgeAmountCanny=%6.2f\n', edgeAmountCanny);
end



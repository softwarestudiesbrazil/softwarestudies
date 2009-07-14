function colorTexture(inputPath,D)

currfolder = inputPath;
myfiles=dir([currfolder,'*.jpg']);
nimages = length(myfiles);

resultf = fopen([currfolder 'stats.txt'],'w');
printHeader(resultf);
for i=1:nimages
    disp(['[matlab-colorTexture]..',myfiles(i).name]);
    Image = imread([currfolder,myfiles(i).name]);
    
    % 5 features for each channel = 5*3 = 15
    color_feat_rgb = basicRGB(Image);
    % 5 features for each channel = 5*3 = 15
    color_feat_hsv = basicHSV(Image);
    % 7 features
    texture_feat = basicTexture(Image,D);
    
    % total = 27 features
    vfeat = [color_feat_rgb color_feat_hsv texture_feat];
    printResult(resultf, myfiles(i).name, vfeat);
end
fclose(resultf);

end

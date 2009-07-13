function colorTexture(inputPath)

% basicTexture parameter
D = 1;

currfolder = inputPath;
myfiles=dir([currfolder,'*.jpg']); 
nimages = length(myfiles);
disp(['[matlab-colorTexture]Processing ' currfolder ' with ' num2str(nimages) ' images...']);

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

disp('[matlab-colorTexture]Done');

end

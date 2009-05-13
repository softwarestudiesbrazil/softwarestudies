function batch(inputPath)

close all; 

myfolders = cell(1,1);
myfolders{1}{1} = inputPath;
nfolders = length(myfolders{1});    
for j=1:nfolders
    currfolder = myfolders{1}{j};
    myfiles=dir([currfolder,'*.jpg']); 
    nimages = length(myfiles);
    disp(['Processing folder ' currfolder ' with ' num2str(nimages) ' images...']);

    resultf = fopen([currfolder 'stats.txt'],'w');
    printHeader(resultf);
    for i=1:nimages
        disp(['..',myfiles(i).name]);
        Image = imread([currfolder,myfiles(i).name]);

        %6 features for each channel = 3*6 = 18
        color_feat_rgb = colorAtrib(Image); 

        %13 features
        glcm = h_cooccurrence(rgbToGray(Image),1,256); %you may want to vary the parameters 1,256
        texture_feat=h_getTextFeat(glcm);

        vfeat = [color_feat_rgb texture_feat];
        printResult(resultf, myfiles(i).name, vfeat);
    end
    fclose(resultf);
end %end nfolders

disp('Done')    

end

%-----------------------------------------
%Routine to run a batch processing 
%-----------------------------------------------------

close all; 
%disp('***********************************')
%disp('Culturevis - http://culturevis.com/')
%disp('This code extract color and texture features of images from folders specified in input.txt file')
%donehomework = input('Did you create a text file (input.txt) with folders to be investigated (y/n)?','s');
%disp('***********************************')
%if strcmp(donehomework,'y')

myfolders = initialize();%init routine
nfolders = length(myfolders{1});    
for j=1:nfolders
    currfolder = myfolders{1}{j};
    myfiles=dir([currfolder,'*.jpg']); 
    nimages = length(myfiles);
    disp(['Processing folder ',currfolder, ' with ', num2str(nimages), ' images....']);

    % get directory name
    C = textscan(currfolder, '%s', 'delimiter', '/');
    
    resultf = fopen([currfolder char(C{1}(end)) '.result.txt'],'w');
    printHeader(resultf);
    for i=1:nimages
        disp(['..',myfiles(i).name]);
        Image = imread([currfolder,myfiles(i).name]);
        %6 features for each channel = 3*6 = 18
        color_feat_rgb = colorAtrib(Image); % you may want to choose one of the two, they can be extremely correlated!
        %6 features for each channel = 3*6 = 18
	%color_feat_lab = colorAtribLab(Image);        
        %13 features
        glcm = h_cooccurrence(rgbToGray(Image),1,256); %you may want to vary the parameters 1,256
        texture_feat=h_getTextFeat(glcm);
        vfeat = [color_feat_rgb color_feat_lab texture_feat];
        %featurefile = [currfolder myfiles(i).name(1:end-4) '.txt'];
        %saveTable(vfeat,featurefile);
        printResult(resultf, myfiles(i).name, vfeat);
    end
fclose(resultf);
end %end nfolders

%else
%    disp('Please create a txt file with folders to be investigated')
%    disp('Example of content of an input.txt:')
%    disp('/u5/yourname/Culturevis/')
%    disp('*** remember to start and finish with / ***')
%end
disp('Done')    

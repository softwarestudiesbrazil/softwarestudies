function bestColors(directory,n,k,outputImg)

if nargin < 2
   n = 16;
end

if nargin < 3
    k = 1;
end

if nargin < 4
    outputImg = 0;
end

files = dir(fullfile(directory,'*.jpg')); 
nimages = length(files);
disp(['[matlab-bestColors]Processing ',directory, ' with ', num2str(nimages), ' images....']);

if nimages > 0
      
resultf = fopen(fullfile(directory,'result.txt'),'w');

% column label
fprintf(resultf,'filename');
for j=1:k
    fprintf(resultf,',Color%d_R,Color%d_G,Color%d_B,Color%d_Percentage',j,j,j,j);
end
fprintf(resultf,'\n');

% data type
fprintf(resultf,'string');
for j=1:k
    fprintf(resultf,',float,float,float,float');
end
fprintf(resultf,'\n');

for i=1:nimages
    full_filename = fullfile(directory,files(i).name);
    disp(['[matlab-bestColors]..' full_filename]);
    T = color_rgb(full_filename,n,k,outputImg);
    fprintf(resultf,'%s',files(i).name);
    for j=1:k
        fprintf(resultf,',%.1f,%.1f,%.1f,%.4f',T(j,:));
    end
    fprintf(resultf,'\n');
end
fclose(resultf);

disp('[matlab-bestColors]Done')    

end
end

n = 16;
k = 2;
directory = '/home/scheaman/workspace/softwarestudies/datasets/rothko/';

files = dir([directory,'*.jpg']); 
nimages = length(files);
disp(['Processing folder ',directory, ' with ', num2str(nimages), ' images....']);

% get directory name
C = textscan(directory, '%s', 'delimiter', '/');
    
resultf = fopen([directory char(C{1}(end)) '.result_' num2str(n) '_' num2str(k) '.txt'],'w');

fprintf(resultf,'filename');

for j=1:k
    fprintf(resultf,',Color%d_R,Color%d_G,Color%d_B,Color%d_Percentage',j,j,j,j);
end
fprintf(resultf,'\n');

for i=1:nimages
    disp(['..',files(i).name]);
    T = color([directory,files(i).name],n,k);
    fprintf(resultf,'%s',files(i).name);
    for j=1:k
        fprintf(resultf,',%.4f,%.4f,%.4f,%.4f',T(j,:));
    end
    fprintf(resultf,'\n');
end
fclose(resultf);

disp('Done')    

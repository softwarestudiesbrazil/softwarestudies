function adaptiveColorQ(directory,n,k,outputImg)

if nargin < 2
    n = 16;
end

if nargin < 3
    k = 2;
end

if nargin < 4
    outputImg = 0;
end

files = dir(fullfile(directory,'*.jpg'));
nimages = length(files);

if nimages > 0
    resultf = fopen(fullfile(directory,'adaptiveColorQ_result.txt'),'w');
    
    % column label
    fprintf(resultf,'filename');
    for j=1:k
        fprintf(resultf,',Color%d_R,Color%d_G,Color%d_B',j,j,j);
        fprintf(resultf,',Color%d_H,Color%d_S,Color%d_V',j,j,j);
        fprintf(resultf,',Color%d_Percentage',j);
    end
    fprintf(resultf,'\n');
    
    % data type
    fprintf(resultf,'string');
    for j=1:k
        fprintf(resultf,',float,float,float');
        fprintf(resultf,',float,float,float');
        fprintf(resultf,',float');
    end
    fprintf(resultf,'\n');
    
    for i=1:nimages
        full_filename = fullfile(directory,files(i).name);
        disp(['[matlab-adaptiveColorQ]..' full_filename]);
        T = color_rgb(full_filename,n,k,outputImg);
        fprintf(resultf,'%s',files(i).name);
        for j=1:k
            fprintf(resultf,',%.2f,%.2f,%.2f',T(j,1:3));
            fprintf(resultf,',%.4f,%.4f,%.4f',T(j,4:6));
            fprintf(resultf,',%.2f',T(j,7));
        end
        fprintf(resultf,'\n');
    end
    fclose(resultf);
end
end

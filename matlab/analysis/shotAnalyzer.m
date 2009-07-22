function [shotSummaries,headers] = shotAnalyzer( resultFile, outputFile )
%SHOTANALYZER Summary of this function goes here
%   Detailed explanation goes here

[data,h,f] = readResultFile(resultFile);

idx = find(strcmp(h,'Shot_number'));

% if the result file contains 'Shot_number'
if size(idx,1) > 0
    
    % remove unwanted columns
    tempData = data;
    tempHeaders = h;
    t_idx = find(strcmp(tempHeaders,'Shot_number') | ...
                 strcmp(tempHeaders,'Cut') | ...
                 strcmp(tempHeaders,'filename'));
    tempData(:,t_idx) = [];
    tempHeaders(t_idx) = [];
    
    % prepare output
    minShot = min(data(:,idx));
    maxShot = max(data(:,idx));
    
    headers = ['Shot_number'; tempHeaders];
    shotSummaries = zeros(maxShot-minShot+1,size(tempData,2)+1);
    
    % process
    for i=minShot:maxShot
        l = find(data(:,idx)==i);
        minL = min(l);
        maxL = max(l);
        shotSummaries(i-minShot+1,1) = i;
        shotSummaries(i-minShot+1,2:end) = mean(tempData(minL:maxL,:),1);
    end
    
    if nargin > 1
        fout = fopen(outputFile,'w');
        % print headers
        fprintf(fout,'%s',char(headers(1)));
        for i=2:size(headers,1)
            fprintf(fout,',%s',char(headers(i)));
        end
        fprintf(fout,'\n');
        % print mean of each column
        for i=1:size(shotSummaries,1)
            fprintf(fout,'%.3f',shotSummaries(i,1));
            for j=2:size(shotSummaries,2)
                fprintf(fout,',%.3f',shotSummaries(i,j));
            end
            fprintf(fout,'\n');
        end
        fclose(fout);
    end
else
    shotSummaries = [];
end



end



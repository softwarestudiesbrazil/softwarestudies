function [summary,headers] = summarizer(resultFile, outputFile)
%SUMMARIZER Summary of this function goes here
%   Detailed explanation goes here


[data,h,f] = readResultFile(resultFile);

summary = mean(data,1);
headers = h;

if nargin == 2
    fout = fopen(outputFile,'w');
    % print headers
    fprintf(fout,'%s',char(headers(1)));
    for i=2:size(headers,1)
        fprintf(fout,',%s',char(headers(i)));
    end
    fprintf(fout,'\n');
    % print mean of each column
    fprintf(fout,'%.3f',summary(1));
    for i=2:size(summary,2)
        fprintf(fout,',%.3f',summary(i));
    end
    fprintf(fout,'\n');
    fclose(fout);
end

end


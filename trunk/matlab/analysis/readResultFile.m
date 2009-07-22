function [ data, headers filenames ] = readResultFile( resultfile )
%READRESULTFILE Read result.txt produced by CAscript

% reading data
rawdata = textread(resultfile,'%s');
% read header
headers = textscan(rawdata{1},'%s','delimiter',',');
headers = headers{:};
% extract data without headers
N = length(rawdata)-2;
data = zeros(N,1);
filenames = cell(N,1);
for i=1:N
    eachLine = textscan(rawdata{i+2},'%s','delimiter',',');
    filenames(i) = eachLine{1}(1);
    for j=2:length(eachLine{1})
        data(i,j) = str2double(eachLine{1}(j));
    end
end

% remove NaN
data(isnan(data)) = 0;

end


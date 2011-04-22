function data = readResultFile( resultfile )
%READRESULTFILE Read result file

fid = fopen(resultfile,'r');

% read header
line = fgets(fid);
C = textscan(line,'%s','delimiter',',');
data.header = C{1}';
% remove filename from header
data.header = data.header(2:end);

% read datatype
line = fgets(fid);
C = textscan(line,'%s','delimiter',',');
data.type = C{1}';

% read the rest
line = fgets(fid);
data.value = zeros(1,length(data.header));
data.filename = {};
i = 1;
while ischar(line)
    C = textscan(line,'%s','delimiter',',');
    data.filename{i} = char(C{1}(1));
    data.value(i,:) = str2double(C{1}(2:end))';
    line = fgets(fid);
    i = i+1;
end

fclose(fid);

end


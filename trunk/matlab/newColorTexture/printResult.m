function printResult( file, filename, data )

separator = ',';
EOL = '';

fprintf(file,'%s',filename);
for i=1:size(data,2)
    fprintf(file,'%s%f',separator,data(i));
end
fprintf(file,'%s\n',EOL);

end

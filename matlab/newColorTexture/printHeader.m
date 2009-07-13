function printHeader( file )

separator = ',';
EOL = '';

colorChannels = {'Red','Green','Blue','Hue','Sat','Value'};
colorFeatureNames = {'Mean','Median','Std','Skewness','Kurtosis'};

textureFeatureNames = {'Entropy','Contrast','Correlation', ...
                       'Energy','Homogeneity','Brightness_Mean',...
                       'Brightness_Std','EdgeAmountSobel'};
% column header
fprintf(file,'filename');
for i=1:size(colorChannels,2)
    for j=1:size(colorFeatureNames,2)
        fprintf(file,'%s%s_%s', separator, colorChannels{i}, ... 
        colorFeatureNames{j});
    end
end
for i=1:size(textureFeatureNames,2)
    fprintf(file,'%s%s',separator, textureFeatureNames{i});
end
fprintf(file,'%s\n',EOL);

% data type
fprintf(file,'string');
for i=1:38
    fprintf(file,'%sfloat',separator);
end
fprintf(file,'%s\n',EOL);

end

function analyzeImage( inputFile, outputFile )

  % read files from the list
  fid = fopen(inputFile,'r');
  C = textscan(fid,'%s');
  fclose(fid);

  % create output file
  ofid = fopen(outputFile,'w');
  
  filenames = C{1};
   
  % first file of the list
  I = imread(char(filenames(1)));
  [d1,h1] = basicInfo(I);  
  d2 = [];
  h2 = [];
  %[d2,h2] = GLCMInfo(I,2);
  data = [d1 d2];
  header = [h1 h2];

  % print header
  fprintf(ofid,'Filename');
  for j=1:length(header)
      fprintf(ofid,',%s',char(header(j)));
  end
  fprintf(ofid,'\n');
  
  % print data
  fprintf(ofid,'%s',char(filenames(1)));
  for j=1:length(data)
      fprintf(ofid,',%.4f',data(j));
  end
  fprintf(ofid,'\n');
  
  % for each input file
  for i=2:length(filenames)
      I = imread(char(filenames(i)));
      [d1] = basicInfo(I);
      %[d2] = GLCMInfo(I,2);
      d2 = [];
      data = [d1 d2];
      fprintf(ofid,'%s',char(filenames(i)));
      for j=1:length(data)
        fprintf(ofid,',%.4f',data(j));
      end
      fprintf(ofid,'\n');
  end
  
  % close the output file
  fclose(ofid);
  
end
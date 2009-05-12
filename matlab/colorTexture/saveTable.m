%--------------------------------------------------------------------------
%function saveTable(tableCell,tablename); 
%   GLcell(cellnumber,:) = [meanz,avgnuma,avgdapi,stdnuma,stddapi];     
function saveTable(M,tablename)

idf = fopen(tablename,'wt');
strf=repmat('%f ',1,size(M,2));
fprintf(idf,[strf,'\n'],M');%saving glcm matrix! NOTICE: must transpose
fclose(idf);
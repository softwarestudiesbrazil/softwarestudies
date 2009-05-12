%function [Numa,Segm,q,d,cellid,parentdir] = getParams()
%This function get the init parameters, init variables, etc.
 
function myfolders=getParams()
    
% if ispc
%     br='\'; %bar used for string formation
%     commonpath='C:\user\yourname'; %Windows
% else
%     br='/'; %Linux
%     commonpath='/home/yourname/folder/myexps'; 
% end
% %File input PATH
% str{1}=[br,'nonpretty',br,'exp12',br,'folder12',br];
% str{2}=[br,'nonpretty',br,'exp12',br,'folder1',br];
% str{3}=[br,'nonpretty',br,'exp12',br,'folder2',br];
% str{4}=[br,'nonpretty',br,'exp12',br,'folder3',br];
% str{5}=[br,'nonpretty',br,'exp5',br,'19au02.01',br];
% str{6}=[br,'nonpretty',br,'exp5',br,'19au02.03',br];
% str{7}=[br,'nonpretty',br,'exp5',br,'19au02.04',br];
% str{8}=[br,'nonpretty',br,'exp5',br,'19au02.12',br];
% % str{9}=[br, 'pretty',  br];
% %----------------------end input PATH
% path=[commonpath,str{i}];

 fid = fopen('input.txt');
 myfolders = textscan(fid,'%s%*[^\n]');
 fclose(fid);
 
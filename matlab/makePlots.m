function makePlots(detailFile)

   fid = fopen(detailFile,'rt');

   if (fid < 0) 
     return;
   end
   
   data = textscan(fid,'%f %f %f %f %f %f','headerlines',1);
   fclose(fid);
   
   figure(1);
   hist(data{6},20);
   title(strcat('Line orientation from ', detailFile));
   xlabel('Degree from x-axis');
   ylabel('Frequency');
   axis tight;
   h = findobj(gca,'Type','patch');
   set(h,'FaceColor','r','EdgeColor','w');
   print(1,'-dpng',strcat(detailFile,'.orientation.png'));

   figure(2);
   hist(data{5},(0:0.05:1));
   title(strcat('Straightness from ', detailFile));
   xlabel('Straightness');
   ylabel('Frequency');
   axis tight;
   h = findobj(gca,'Type','patch');
   set(h,'FaceColor','r','EdgeColor','w');
   print(2,'-dpng',strcat(detailFile,'.straightness.png'));

   figure(3);
   hist(data{2},20);
   title(strcat('Number of turns from ', detailFile));
   xlabel('Number of turns');
   ylabel('Frequency');
   h = findobj(gca,'Type','patch');
   set(h,'FaceColor','r','EdgeColor','w');
   print(3,'-dpng',strcat(detailFile,'.turns.png'));
   
   figure(4);
   hist(data{3},20);
   title(strcat('Line length from ', detailFile));
   xlabel('Line lenght');
   ylabel('Frequency');
   h = findobj(gca,'Type','patch');
   set(h,'FaceColor','r','EdgeColor','w');
   print(4,'-dpng',strcat(detailFile,'.length.png'));
   
   

   
   
end



directory = '/home/scheaman/workspace/softwarestudies/datasets/rothko/';

files = dir([directory,'*.jpg']); 
nimages = length(files);
disp(['Processing folder ',directory, ' with ', num2str(nimages), ' images....']);

for i=1:2 %nimages
    close all;
    disp(['..',files(i).name]);
    vis_color_rgb([directory  files(i).name],8);
    print(1,'-dpng', [files(i).name '.out.png']);
end

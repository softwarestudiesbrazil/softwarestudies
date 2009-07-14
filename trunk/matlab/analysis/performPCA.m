function performPCA( data, filenames, projectDir, imgWidth )
%PERFORMPCA Perform PCA and make a 2d scatter plot using 1st and 2nd
% components as axes.

if nargin < 4
    imgWidth = 10;
end

[coeff,score,latent] = princomp(data);

pctExplained = latent' ./ sum(latent);

% top 2 components
top2 = coeff(:,1:2);

% plot data according to the top 2 components

% save as tab-delimited file
output = score(:,1:2); 
save 'pca_top2_score.txt' output -ASCII -tabs
save 'pca_top2_basis.txt' top2 -ASCII -tabs

%%% plot image onto the scatter plot
figure; 
xlabel(['1st Component (' num2str(pctExplained(1)*100,2) '% explained)']);
ylabel(['2nd Component (' num2str(pctExplained(2)*100,2) '% explained)']);

hold on;
for i=1:size(data,1)
    I = imread([projectDir '/images/' filenames{i}]);
    height = size(I,1) * imgWidth/size(I,2);
    image([score(i,1) score(i,1)+imgWidth],[score(i,2)+height score(i,2)],I);
end
end


%>>>>>>>>> EXTREMELY IMPORTANT!!!!!!!   <<<<<<
%Obs1: This code is designed to images which background is -1 and ROI
%otherwise.  Pixels = -1 are discarded in the texture evaluation
%If your input is not a segmented image, disregard Obs1.
% cooccurrence.m
% calculates the cooccurence matrix, P, of an image, i
% d is the distance of the i pixel from the j pixel, and should be a two element vector, such as [1,1], 
% allowing P calculation for one unique direction 
% ISOTROPIC COOCCURRENCE MATRIX
%Daniela Ushizima - danicyber@gmail.com

function P= cooccurrence(image, d,quantiz)

%image=double(image);
%imagesc(image);pause; colormap diphist(image);pause
[rows, cols] = size(image);
maxele = quantiz; %indexing starts with one

% Initialize P to be all zeros
P0 = zeros(maxele, maxele);
P45 = P0;
P90 = P0;
P135 = P0;

for row = 1:rows
   for col = 1:cols
       
      if col <= (cols - d)
          %0 degree 
          i = image(row, col) + 1;%pois pode ser zero e 'e usado como indice
          j = image(row, col + d) + 1;
          if isIndexOk(i,j)
              P0(i,j) = P0(i,j) + 1;
          end
          %45 degree
          if row <= (rows - d)
              i = image(row, col) + 1;%pois pode ser zero e 'e usado como indice                 
              j = image(row + d, col + d) + 1;
              if isIndexOk(i,j)
                  P45(i,j) = P45(i,j) + 1;
              end
          end
      end
      %90 degree
      if row > d
          i = image(row, col) + 1;%pois pode ser zero e 'e usado como indice                 
          j = image(row - d, col) + 1;
          if isIndexOk(i,j)
              P90(i,j) = P90(i,j) + 1;
          end
          %135 degree
          if col > d
              i = image(row, col) + 1;%pois pode ser zero e 'e usado como indice                 
              j = image(row - d, col - d) + 1;
              if isIndexOk(i,j)
                  P135(i,j) = P135(i,j) + 1;             
              end
          end
      end
      
   end %FOR
end %FOR



P0=P0/sum(sum(P0));
P45=P45/sum(sum(P45));
P90=P90/sum(sum(P90));
P135=P135/sum(sum(P135));

P = (1/8).*(P0 + P45 + P90 + P135 + P0' + P45' + P90' + P135');
%Normalize P MUDAR ISSO AQUI - NORMALIZAR UMA POR UMA
P=P/sum(sum(P));

%-------------------------------------
%Function to check if the index is fine

function boo=isIndexOk(i,j)
boo = 1;
if (i<=0) | (j<=0)
    boo = 0;
end
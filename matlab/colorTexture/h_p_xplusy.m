%function pxy=p_xplusy(p)
%Function to calculate a vector that is a function of the sum of the matrix coordinates
%i.e. x and y are the coordinates (row and column) of an entry in the
%co-occurrence matrix, and p_{x+y} is the probability of co-occurrence
%matrix coordinates summing to x+y

function pxy=p_xplusy(p)

Ng=size(p,1);
pxy=zeros(1,2*Ng-1);
for i=1:Ng
    for j=1:Ng
        k=i+j-1; %to have the vector varying from 1 to 2*Ng-1
        pxy(k)=pxy(k)+sum(sum(p(i:Ng,j:Ng)));
    end
end

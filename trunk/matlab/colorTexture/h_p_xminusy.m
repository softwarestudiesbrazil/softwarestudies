%function pxy=p_xminusy(p)
%Function to calculate a vector that is a function of the difference of the matrix coordinates
%i.e. x and y are the coordinates (row and column) of an entry in the
%co-occurrence matrix, and p_{x-y} is the probability of co-occurrence
%matrix coordinates summing to x-y

function px_y=p_xminusy(p)

Ng=size(p,1);
px_y=zeros(1,Ng);
for i=1:Ng
    for j=1:Ng
        k=abs(i-j)+1; %to have index varying from 1 to Ng
        px_y(k)=px_y(k)+sum(sum(p(i:Ng,j:Ng)));
    end
end


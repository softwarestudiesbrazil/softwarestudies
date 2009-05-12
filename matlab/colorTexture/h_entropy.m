% entropy.m
% calculates the entropy given a co-occurrence matrix, P

function [ent] = entropy(P)

%[A,B] = size(P);

ent = 0;

ent= - sum( sum( P.* log2(P+eps) ) );

% for a = 1:A
%    for b = 1:B
%        ent = ent + P(a,b) * log2(P(a,b)+eps); %eps is a matlab variable, an arbitrarily small positive constant    
%    end
% end
    
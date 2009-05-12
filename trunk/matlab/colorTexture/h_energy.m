% energy.m
% calculates the energy given a co-occurrence matrix, P
% also known as angular second moment

function [e] = energy(P)

e=sum(sum(P.^2));

% 
% [A,B] = size(P);
% 
% e = 0;
% 
% for a = 1:A
%    for b = 1:B
%       e = e + P(a,b) ^ 2;
%    end
% end
    
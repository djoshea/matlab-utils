function [nR, nC] = BestSubplots(nP)

% [nR, nC] = BestSubplots(N)
%
% Calculates the best distribution of subplots for N plots
%
% INPUTS
%   nP = number of subplots to place
%
% OUTPUTS
%   nR, nC = number of rows and columns
%
% ADR 2013

nR = ceil(sqrt(nP));
nC = ceil(nP/nR);
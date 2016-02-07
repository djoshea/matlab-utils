function [output, m] = L_Ratio(FD, ClusterSpikes)

% output = L_Ratio(FD, ClusterSpikes)
%
% L-ratio
% Measure of cluster quality
%
% Inputs:   FD:           N by D array of feature vectors (N spikes, D dimensional feature space)
%           ClusterSpikes: Index into FD which lists spikes from the cell whose quality is to be evaluated.
%
% Output: a structure containing three components
%           Lratio, L, df

% find # of spikes in this cluster
[nSpikes, nD] = size(FD);

nClusterSpikes = length(ClusterSpikes);

% mark spikes which are not cluster members
NoiseSpikes = setdiff(1:nSpikes, ClusterSpikes);

m = mahal(FD, FD(ClusterSpikes,:));
df = size(FD,2);

L = sum(1-chi2cdf(m(NoiseSpikes),df));
Lratio = L/nClusterSpikes;

output.L = L;
output.Lratio = Lratio;
output.df = nD;
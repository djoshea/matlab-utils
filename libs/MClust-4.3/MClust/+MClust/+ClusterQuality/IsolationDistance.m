function IsoDist = IsolationDistance(FD, ClusterSpikes)

% IsoDist = IsolationDistance(FD, ClusterSpikes)
%
% Isolation Distance
% Measure of cluster quality
%
% Inputs:   FD:           N by D array of feature vectors (N spikes, D dimensional feature space)
%           ClusterSpikes: Index into FD which lists spikes from the cell whose quality is to be evaluated.
%
% Created by Ken Harris
% 
% Code by ADR 2012/12, from earlier versions

[nSpikes, nCh] = size(FD);

nClusterSpikes = length(ClusterSpikes);

if nClusterSpikes > nSpikes/2;
    IsoDist = nan; % not enough out-of-cluster-spikes - IsoD undefined
    return
end

InClu = ClusterSpikes;
OutClu = setdiff(1:nSpikes, ClusterSpikes);

%%%%%%%%%%% compute mahalanobis distances %%%%%%%%%%%%%%%%%%%%%
m = mahal(FD, FD(ClusterSpikes,:));

mNoise = m(OutClu); % mahal dist of all other spikes

% calculate point where mD of other spikes = n of this cell
sorted = sort(mNoise);
IsoDist = sorted(nClusterSpikes);

function ClusterFunc_DeleteAllSpikes( self )
% DeleteAllSpikes
% remove all points from the cluster

%================================================
% PARAMETERS
%================================================
%================================================
% MAIN CODE
%================================================

self.getAssociatedCutter().StoreUndo(['Delete all spikes:' self.name]);

self.SetSpikes([]);


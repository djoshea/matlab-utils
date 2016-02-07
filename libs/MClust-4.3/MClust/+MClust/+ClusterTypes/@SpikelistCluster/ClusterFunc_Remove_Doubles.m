function ClusterFunc_Remove_Doubles( self )
% RemoveDoubleCounts
% remove all points which precede another point in the cluster by <1 ms
% and put them in a new cluster

%================================================
% PARAMETERS
%================================================

minThreshold = 0.001; % less than 1 ms apart: double count

%================================================
% MAIN CODE
%================================================

self.getAssociatedCutter().StoreUndo(['Remove Doubles:' self.name]);

MCD = MClust.GetData();

S = self.GetSpikes();
T = MCD.FeatureTimestamps(S);

ISIs = [Inf; diff(T)];

badISIs = ISIs < minThreshold; 

if any(badISIs)
	self.RemoveSpikes(S(badISIs));
	
	newCluster = self.MakeCopy();
	newCluster.RenameCluster([self.name ': <1ms']);
	newCluster.RemoveSpikes(S(~badISIs));
end









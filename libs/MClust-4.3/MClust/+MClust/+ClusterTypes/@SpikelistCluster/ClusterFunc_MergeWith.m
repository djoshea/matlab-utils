function  ClusterFunc_MergeWith(self)

% ClusterFunc_MergeWith (SpikelistCluster)
%
% Creates new cluster with both sets of spikes
%
% ADR 2013-08-026 Allow user to modify MergeName

%%%%%%%%%%%%%%%%%%
% PARAMETERS
%%%%%%%%%%%%%%%%%%

%MergeName = 'ByNumber';
%MergeName = 'ByName';
MergeName = 'ByBoth';

%%%%%%%%%%%%%%%%%%%%%%

MCC = self.getAssociatedCutter();

names = MCC.getClusterNames();
[clustersToMerge, OK] = listdlg('ListString', names, 'PromptString', 'ClustersToMerge');

if OK && ~isempty(clustersToMerge)
    MCC.StoreUndo('Merge Clusters');
    newClust = MClust.ClusterTypes.SpikelistCluster();
    newClust.SetParms(self);
    
    switch MergeName
        case 'ByNumber'
            newClust.RenameCluster(sprintf('Merge: %d', MCC.findSelf(self)));
        case 'ByName'
            newClust.RenameCluster(sprintf('Merge: (%s)', self.name));
        case 'ByBoth'
            newClust.RenameCluster(sprintf('Merge: %d(%s)', MCC.findSelf(self), self.name));
        otherwise
            newClust.RenameCluster('A Merge cluster.');
    end        
    for iC = 1:length(clustersToMerge)
        C0 = MCC.Clusters{clustersToMerge(iC)};
        if ~isequal(self, C0)
            newClust.AddSpikes(C0.GetSpikes());
            
            switch MergeName
                case 'ByNumber'
                    newClust.RenameCluster(sprintf('%s + %d', newClust.name, MCC.findSelf(C0)));
                case 'ByName'
                    newClust.RenameCluster(sprintf('%s + (%s)', newClust.name, C0.name));
                case 'ByBoth'
                    newClust.RenameCluster(sprintf('%s + %d(%s)', newClust.name, MCC.findSelf(C0), C0.name));
                otherwise
                    newClust.RenameCluster('A Merge cluster.');
            end
        end
    end
    MCC.Clusters{end+1} = newClust;
    MCC.ReGo();
end
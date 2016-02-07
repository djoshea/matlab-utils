function OK = WriteCQfiles(self)

% OK = WriteWVfiles(MCD)
% no longer writing SNR

MCD = self;
MCS = MClust.GetSettings();

nClust = length(MCD.Clusters);

for iC = 1:nClust
    tSpikes = MCD.Clusters{iC}.GetSpikes;
    if ~isempty(tSpikes)
        CluSep.L_Ratio = MCD.Clusters{iC}.CalculateLRatio();
        CluSep.IsolationDistance = MCD.Clusters{iC}.CalculateIsolationDistance();
        %CluSep.SNR = MCD.Clusters{iC}.CalculateSNR();
    
        fnCQ = [MCD.TfileBaseName(iC) '-CluQual.mat'];
        
        CluSep.Features = MCS.ClusterSeparationFeatures;
        CluSep.ChannelValidity = MCS.ChannelValidity;
        CluSep.nSpikes = length(tSpikes);
                
        save(fnCQ,'CluSep','-mat');
    end
end

OK = true;
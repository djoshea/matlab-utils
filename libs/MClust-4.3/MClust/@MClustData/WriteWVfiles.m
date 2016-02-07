function OK = WriteWVfiles(self)

% OK = WriteWVfiles(MCD)

MCD = self;

nClust = length(MCD.Clusters);

WV = MCD.LoadNeuralWaveforms();
WVT = WV.range();
WVD = WV.data();

for iC = 1:nClust
    tSpikes = MCD.Clusters{iC}.GetSpikes;
    if ~isempty(tSpikes)
        fnWV = [MCD.TfileBaseName(iC) '-wv.mat'];

        [mWV, sWV, xrange] = MClust.AverageWaveform(tsd(WVT(tSpikes), WVD(tSpikes, :,:))); %#ok<NASGU,ASGLU>
        
        save(fnWV,'mWV','sWV','xrange','-mat');
    end
end

OK = true;
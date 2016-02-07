function SNR = CalculateSNR( self, WV )
% SNR = CalculateSNR(self)

MCD = MClust.GetData();
mySpikes = self.GetSpikes();

if nargin==1
    WV = MCD.LoadNeuralWaveforms(mySpikes, 2);
end
[~, nCh, ~] = size(WV.data);
mWV = MClust.AverageWaveform(WV); 
[~, maxPeak] = max(abs(mWV));

noiseSpikes = setdiff(1:MCD.nSpikes(), mySpikes);
WV = MCD.LoadNeuralWaveforms(noiseSpikes, 2);

[Noise_mWV Noise_sWV] = MClust.AverageWaveform(WV); 

SNR = nan(nCh,1);
for iCh = 1:nCh
    SNR(iCh) = (mWV(maxPeak(iCh),iCh)- Noise_mWV(maxPeak(iCh),iCh))./Noise_sWV(maxPeak(iCh),iCh);
end

end


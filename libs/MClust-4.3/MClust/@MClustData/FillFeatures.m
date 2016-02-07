function OK = FillFeatures(self)

% CalculateFeatures and save them
MCS = MClust.GetSettings();

% Which features need to be calculated
featuresToCalc = MCS.FeaturesToUse;
try
	[self.FeatureTimestamps, self.Features] = MClust.CalculateFeatures(featuresToCalc);
	OK = true;
catch ME
	disp('Failed to fill (calculate) features.'); ME
	self.TTfn = ''; % unload data
	OK = false;
end
end


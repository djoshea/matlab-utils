function [FeatureTimestamps, Features] = CalculateFeatures(featuresToCalc)

% [FeatureTimeStamps,Features] = CalculateFeatures(featuresToCalc)
%
% input string list of featurenames
%
% output
%   FeatureTimeStamps = timestamps
%   Features = set of features

MCS = MClust.GetSettings();
MCD = MClust.GetData();

nFeat = length(featuresToCalc);

featureFile = cell(nFeat,1);
needToCalculate = true(nFeat,1);
for iF = 1:nFeat
	featureFile{iF} = fullfile(MCD.FDdn, [MCD.TTfn '_' featuresToCalc{iF} MCD.FDext]);
	% does the feature already exist
	if exist(featureFile{iF}, 'file')
		% might not need to calculate because already exists
		needToCalculate(iF) = false;
		
		% has ChannelValidity Changed?
		load(featureFile{iF}, 'ChannelValidity', '-mat');
		if any(ChannelValidity~=MCS.ChannelValidity) %#ok<NODEF>
			% need to calculate because Channel Validity has not changed
			needToCalculate(iF) = true;
		end

		load(featureFile{iF}, 'Normalized', '-mat');
		if Normalized~=MCS.normalizeYN %#ok<NODEF>
			% need to calculate because normalize has not changed
			needToCalculate(iF) = true;
		end

	end
end

% Calculate features
if any(needToCalculate)
	
	% Load neural data (as a whole for now - only do blocks if we need it)
	WV = MCD.LoadNeuralWaveforms();
	
	nSpikes = length(WV.range());
	FeatureTimestamps = WV.range(); 
	FeatureIndex = 1:nSpikes; %#ok<NASGU>
	TT_file_name = MCD.TTfn; %#ok<NASGU>
	ChannelValidity = MCS.ChannelValidity;
	
	for iF = 1:nFeat
		if needToCalculate(iF)
			[FeatureData, FeatureNames, FeaturePar] = feval(featuresToCalc{iF}, WV, ChannelValidity); %#ok<NASGU>
			FD_av = mean(FeatureData);
			FD_sd = std(FeatureData)+eps;
			if MCS.normalizeYN
				% standardize data to zero mean and unit variance
				FeatureData =(FeatureData-repmat(FD_av,nSpikes,1))./repmat(FD_sd,nSpikes,1); %#ok<NASGU>
				Normalized = true;
			else
				Normalized = false;
			end
			save(featureFile{iF}, ...
				'FeatureIndex','FeatureTimestamps','FeatureData', 'ChannelValidity', 'FeatureNames', ...
				'Normalized', 'FeaturePar','FD_av','FD_sd', 'TT_file_name', '-mat');
			disp([  ' Wrote ' featureFile{iF} ' as a .mat formatted file']);
        else
            disp([  ' Skipping ' featureFile{iF} ', already calculated.']);
		end
	end
else
	for iF = 1:nFeat
            disp([  ' Skipping ' featureFile{iF} ', already calculated.']);
	end		
end

% Fill list of features
Features = {};
for iF = 1:nFeat
	load(featureFile{iF}, 'FeatureTimestamps', 'FeatureNames', '-mat')
	for iD = 1:length(FeatureNames)
		Features{end+1} = MClust.Feature(FeatureNames{iD}, featureFile{iF}, iD);
	end
end
FeatureTimestamps = FeatureTimestamps;
	
end
		

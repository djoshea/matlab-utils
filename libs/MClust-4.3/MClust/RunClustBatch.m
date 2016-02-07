function RunClustBatch(varargin)

% RunClustBatch
%
%   rebuilt completely for MClust 4.0
%
% No longer uses batch files.  Now is a function that takes parameters.
% parameters are passed as string-set pairs.  For example:
% RunClustBatch('minClusters', 10, 'maxClusters', 25);
% RunClustBatch();
% RunClustBatch('fcTT', {'TT1.ntt', 'TT2.ntt'});
% 
% fcTT = {}; Pass in a cell array of filenames
% TText = '.ntt';
% StartingDirectory = pwd;
% FDDirectory = 'FD';
% channelValidity = true(4,1);
% LoadingEngine = 'LoadTT_NeuralynxNT';
% minClusters = 20;
% maxClusters = 60;
% maxSpikesBeforeSplit = []; % if isempty then don't split
% featuresToCompute = {'feature_Energy', 'feature_EnergyD1', 'feature_Peak', 'feature_WavePC1', 'feature_Time'};
% featuresToUse = {'feature_Energy', 'feature_EnergyD1'};
% SubSetAt = 1e6;
% GeneralSubSetRate = 10;  % rate is 1/GSSR

% ADR 2014 23 January added subsetting

% prepare parameters

USECONDOR = false;

fcTT = [];
TText = '.ntt';
StartingDirectory = pwd;
FDDirectory = 'FD';
channelValidity = true(4,1);
LoadingEngine = 'LoadTT_NeuralynxNT';

minClusters = 20;
maxClusters = 60;
maxSpikesBeforeSplit = []; % if isempty then don't split

featuresToCompute = {'feature_Energy', 'feature_EnergyD1', 'feature_Peak', 'feature_WavePC1', 'feature_Time'};
featuresToUse = {'feature_Energy', 'feature_EnergyD1'};

SubSetAt = 1e6;
GeneralSubSetRate = 10;
process_varargin(varargin);

% make sure ChannelValidity is 4x1 - if it's 1x4 rotate.
if all(size(channelValidity)==[1 4])
    channelValidity = channelValidity';
else
    assert(all(size(channelValidity)==[4,1]),...
        'channelValidity must be a 4x1 logical matrix');
end

% find tetrodes to read
if isempty(fcTT)
	fcTT = FindFiles(['*' TText], 'StartingDirectory', StartingDirectory, 'CheckSubdirs', false);
end

% create MClust so have access to settings and data objects
global MClustInstance
if isa(MClustInstance, 'MClust0')
	error('MClust:RunClustBatch','MClust is already running.  Cannot run batch and MClust at the same time.');
end
MClustInstance = MClust0();
MClustInstance.Initialize(false);
MCS = MClust.GetSettings();
MCD = MClust.GetData();

% fill settings and data objects with passed in parameters
MCS.ChannelValidity = channelValidity;
MCS.nCh = length(channelValidity);
MCS.NeuralLoadingFunction = LoadingEngine;
MCD.FDdn = fullfile(StartingDirectory, FDDirectory);
if ~exist(MCD.FDdn, 'dir')
	assert(mkdir(MCD.FDdn), 'Could not make FD.');
end
	
% STEP 1: PREPARE
nTT = length(fcTT);
kkFN = cell(nTT,1); nKKfiles = ones(nTT,1); nKKFeatures = nan(nTT,1);
SubSetRate = ones(nTT,1);
for iTT = 1:nTT	  % for each tetrode
	
	% STEP 1A: Create FD files
	[MCD.TTdn MCD.TTfn MCD.TText] = fileparts(fcTT{iTT});
	MClust.CalculateFeatures(featuresToCompute);
	[FeatureTimestamps, featuresTT] = MClust.CalculateFeatures(featuresToUse); % featuresToUse are now feature objects
    
	% STEP 1B: Prepare for KKwik
	% write featuredata into text file for input into KKwik
	[kkFN{iTT} nKKfiles(iTT) nKKFeatures(iTT)] = KlustaKwik.WriteKKwikFeatureFile(...
        fullfile(MCD.FDdn, MCD.TTfn), ...
        featuresTT, ...
        'FeatureTimestamps', FeatureTimestamps, ...
        'maxSpikesBeforeSplit', maxSpikesBeforeSplit);	

    % STEP 1C: Need to subset?
    if length(FeatureTimestamps) > SubSetAt
        fprintf('Subsetting %s at rate of 1/%d\n', MCD.TTfn, GeneralSubSetRate);
        SubSetRate(iTT) = GeneralSubSetRate;
    end
	
end

if nTT==0
	disp('No tetrodes to autocut.');
end
% STEP 2: RUN KKWIK
for iTT = 1:nTT % for each tetrode
	for FILEno = 1:nKKfiles(iTT)
		KlustaKwik.RunOneKKwik(kkFN{iTT}, FILEno, ...
            nKKFeatures(iTT), minClusters, maxClusters,...
            'SubSetRate', SubSetRate(iTT), ...
            'USECONDOR', USECONDOR);
	end
end

% STEP END: close down
clear global MClustInstance

	
end % RunClustBatch

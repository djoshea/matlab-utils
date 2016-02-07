function [fnBase, nFiles, nKKFeatures] = WriteKKwikFeatureFile(fnBase, features, varargin)

% [fnBase, nFiles] = WriteKKwikFeatureFile(fnBase, features, varargin)
%
% Parameters 
%    maxSpikesBeforeSplit; 0 means don't split
%    spikes; [] means use all spikes

MCD = MClust.GetData();

% -------------------
% Parms

maxSpikesBeforeSplit = 0;  % use 0 for don't split
spikes = [];
FeatureTimestamps = MCD.FeatureTimestamps;

process_varargin(varargin);


% -------------------

nF = length(features);
if isempty(spikes)
    nSpikes = length(FeatureTimestamps);
else
    nSpikes = length(spikes);
end

FD = nan(nF, nSpikes);
% count features
for iF = 1:nF
    if isempty(spikes)
        FD(iF,:) = features{iF}.GetData();
    else
        FD0 = features{iF}.GetData();
        FD(iF,:) = FD0(spikes);
    end
    if ~features{iF}.normalizedYN % KKwik needs it normalized
        FD(iF,:) = (FD(iF,:)-mean(FD(iF,:)))/std(FD(iF,:));
    end
end

if ~isempty(maxSpikesBeforeSplit) && maxSpikesBeforeSplit>0 && nSpikes > maxSpikesBeforeSplit
    % split into files
    spikeSplit = 1:maxSpikesBeforeSplit:(nSpikes) ;
    spikeSplit(end+1) = nSpikes+1;  % need to include rest of the data!
    nFiles = length(spikeSplit);
    disp(sprintf('...Split into %d files...', nFiles-1));
    for iFile = 1:(nFiles-1)
        
        spikesToInclude = spikeSplit(iFile):(spikeSplit(iFile+1)-1);
        fnFET = [fnBase '.fet.' num2str(iFile)];
        fnClu = [fnBase '.clu.' num2str(iFile)];
        fp = fopen(fnFET, 'wt'); fprintf(fp, '%d', nF); fclose(fp);
        dlmwrite(fnFET, FD(:,spikesToInclude)', 'roffset', 1, '-append', 'delimiter', ' ');
        
        % ADR 2014-09-12 Need to create translation file
        fnKKmat = [fnBase '.KKmat.', num2str(iFile)];
        save(fnKKmat, 'spikesToInclude', 'fnFET', 'fnClu');
    end
else
    iFile = 1;
    
    spikesToInclude = 1:nSpikes;
    fnFET = [fnBase '.fet.' num2str(iFile)];
    fnClu = [fnBase '.clu.' num2str(iFile)];
    fp = fopen(fnFET, 'wt'); fprintf(fp, '%d', nF); fclose(fp); 
    dlmwrite(fnFET, FD', 'roffset', 1, '-append', 'delimiter', ' ');

    % ADR 2014-09-12 Need to create translation file
    fnKKmat = [fnBase '.KKmat.', num2str(iFile)];
    save(fnKKmat, 'spikesToInclude', 'fnFET', 'fnClu');

end

nFiles = max(iFile);
nKKFeatures = size(FD,1);

end % WriteKKwikFeatures

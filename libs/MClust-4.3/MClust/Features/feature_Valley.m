function [ValleyData, ValleyNames,ValleyPars] = feature_Valley(V, ttChannelValidity, ~)

% MClust
% [ValleyData, ValleyNames] = feature_Valley(V, ttChannelValidity)
% Calculate Valley feature max value for each channel
%
% INPUTS
%    V = TT tsd
%    ttChannelValidity = nCh x 1 of booleans
%
% OUTPUTS
%    Data - nSpikes x nCh Valley values
%    Names - "Valley: Ch"
%
% ADR April 1998
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

TTData = V.data();
[nSpikes, nCh, nSamp] = size(TTData);

f = find(ttChannelValidity);

ValleyData = zeros(nSpikes, length(f));
ValleyNames = cell(length(f), 1);
ValleyPars = {};
for iCh = 1:length(f)
	ValleyData(:,iCh) = squeeze(min(TTData(:, f(iCh), :), [], 3));
	ValleyNames{iCh} = ['Valley: ' num2str(f(iCh))];
end

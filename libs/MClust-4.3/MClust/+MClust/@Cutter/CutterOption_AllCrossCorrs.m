function  CutterOption_AllCrossCorrs(self)

% shows crosscorrs of shows
%
% INPUTS
%
% OUTPUTS
%
% NONE

% ADR 2013
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
% Extensively modified by ADR to accomodate new ClusterOptions methodology
% Modified for MClust 4.0

MCS = MClust.GetSettings();
nClu = length(self.Clusters);
showIt = find(cellfun(@(C)~C.hide, self.Clusters));
nToShow = length(showIt);

figure('NumberTitle', 'off', 'Name','CrossCorrs', 'Tag', MCS.DeletableFigureTag);
for iC = 1:nToShow
	for jC = 1:iC
		C0 = self.Clusters{showIt(iC)}; T0 = C0.GetSpikeTimes();
		C1 = self.Clusters{showIt(jC)}; T1 = C1.GetSpikeTimes();
		ax = subplot(nToShow, nToShow, (iC-1)*nToShow+jC); 
		MClust.CrossCorr(T0, T1, 'axesHandle', ax, ...
			'myTitle', sprintf('%2d x %2d', showIt(iC), showIt(jC)));
		axis off
		set(ax, 'XTick', [], 'YTick', []);
		set(ax, 'box', 'on')
		axis on
	end
end
	
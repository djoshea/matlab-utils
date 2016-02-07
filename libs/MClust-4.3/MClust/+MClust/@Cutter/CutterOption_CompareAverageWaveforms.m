function  CutterOption_CompareAverageWaveforms(self)

% plots average waveforms of only shows
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
%
% Modifed to color by cluster.  Modified to show one plot if requested.

%%%%%%%%%%%%%%%%%%
% PARAMETERS
%%%%%%%%%%%%%%%%%%

OnePlot = true;

%%%%%%%%%%%%%%%%%%%%%%

MCS = MClust.GetSettings();
nClu = length(self.Clusters);
nToShow = sum(cellfun(@(C)~C.hide, self.Clusters));

iShow = 1;
[nR, nC] = MClustUtils.BestSubplots(nToShow);

stringsForLegend = {};

figure('NumberTitle', 'off', 'Name','Average Waveforms', 'Tag', MCS.DeletableFigureTag);
for iC = 1:nClu
    if ~self.Clusters{iC}.hide
        
        WV = self.Clusters{iC}.GetWaveforms();
        [mWV, sWV, xr] = MClust.AverageWaveform(WV);        
        xr(end+1,:) = nan; mWV(end+1,:) = nan; sWV(end+1,:) = nan;
         
        if OnePlot
            ax = subplot(1,1,1);
            hold on
            stringsForLegend = cat(1, stringsForLegend, self.Clusters{iC}.name);
        else
            ax = subplot(nR, nC, iShow); iShow = iShow+1;
        end

        plot(xr(:), mWV(:), 'color', self.Clusters{iC}.color, 'LineWidth',2);
        title(self.Clusters{iC}.name);
        set(gca, 'YLim',MCS.AverageWaveform_ylim);

        axis off
    end
end

if OnePlot
    title('');
    legend(stringsForLegend);
end
end % function

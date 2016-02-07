function Redraw(self)
%
% MClustMainWindow: redraw

MCD = MClust.GetData();
MCS = MClust.GetSettings();

set(self.LoadingEnginePulldown, 'String', self.LoadingEngines, 'Value', self.LoadingEngineValue);

self.FeatureListBoxes.SetLeftList(setdiff(MCS.FeaturesAvailable, MCS.FeaturesToUse));
self.FeatureListBoxes.SetRightList(MCS.FeaturesToUse);

for iV = 1:MCS.nCh
    set(self.ChannelValidityButton{iV}, 'Value', MCS.ChannelValidity(iV));
end

if isempty(MCD.FeatureTimestamps)
    set(self.TTfnLabel, 'String', '', 'BackgroundColor', [0.5 0.5 0.5]);
    set(self.FDCheckBox, 'Value', false);
else
    set(self.TTfnLabel, 'String', MCD.TTfn, 'BackgroundColor', 'c');
    set(self.FDCheckBox, 'Value', true);
end
end

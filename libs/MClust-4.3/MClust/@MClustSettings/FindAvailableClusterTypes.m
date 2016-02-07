function [AvailableTypes, AvailableNames] = FindAvailableClusterTypes(self)

% MClustSettings
%
% What Cluster Types are available?
%
% Returns structure array of names

ClusterTypeList = meta.package.fromName('MClust.ClusterTypes').ClassList;
AvailableTypes = {};

for iC = 1:length(ClusterTypeList)
    if eval([ClusterTypeList(iC).Name '.Modifiable'])
        AvailableTypes{end+1} = ClusterTypeList(iC).Name; %#ok<AGROW>
    end
end
   
AvailableNames = {};
for iC = 1:length(AvailableTypes)
    % get classname without packages
    tmp = textscan(AvailableTypes{iC}, '%s', 'delimiter', '.');
    AvailableNames{iC} = tmp{1}{end}; %#ok<AGROW>
end

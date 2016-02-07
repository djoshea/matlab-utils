function ClusterFunc_Convert(self)

% f = CopyCluster(self)

% ncst 26 Nov 02
% ADR 2008
%

MCS = MClust.GetSettings();
[AvailableTypes, AvailableNames] = MCS.FindAvailableClusterTypes();
[Selection, OK] = listdlg(...
	'ListString', AvailableNames, ...
	'SelectionMode', 'single', ...
	'InitialValue', [], ...
	'Name', 'Available cluster types', ...
	'PromptString', 'Convert cluster to type...');
if OK && ~streq(AvailableTypes{Selection}, class(self))	
	self.getAssociatedCutter().StoreUndo('Convert');
	newClass = AvailableTypes{Selection};
	newCluster = self.Convert(newClass);
end


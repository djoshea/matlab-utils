function CutterOption_RecolorClusters(self)
% RecolorClusters(self)
%
%
% INPUTS
%
% OUTPUTS
%
% NONE

MCD = MClust.GetData();

nColors = max(100, MCD.maxClusters);

colormaps = {'hsv', 'jet', 'copper', 'bone', 'colorcube'};

[Selection, OK] = listdlg('PromptString', 'Select color map to use', ...
	'ListString', colormaps, ...
	'InitialValue', 1, ...
	'Name', 'Colormap', ...
	'SelectionMode', 'single');

if OK
	c = feval(@colormap, sprintf('%s(%d)', colormaps{Selection}, nColors));
	
	ix = mod((1:nColors),10)*10 + floor((1:nColors)/10);
	ix = ix(end:-1:1);
	
	nClust = length(self.Clusters);
	for iC = 2:nClust
		self.Clusters{iC}.ChangeColor(c(ix(iC),:));
    end
    
    self.RedrawClusters();
end
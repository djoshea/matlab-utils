function  ClusterFunc_AddSpikesByGaussian(self)

% PreCut Clusters - ClusterFunction_AddSpikesByConvexHull
%
% Adds ability to add individual spikes

% parameters
thorn = 1;
minSpikes = 100;
sigmaStep = 1.1;

% function

MCC = self.getAssociatedCutter();
MCC.StoreUndo('Add Spikes by Gaussian');

% get axes
xFeat = MCC.get_xFeature(); Xd = xFeat.GetData;
yFeat = MCC.get_yFeature(); Yd = yFeat.GetData;
X = [Xd, Yd];

% starting point
if isempty(MCC.CC_figHandle)
	warning('MClust:Cutter', 'No axes to draw on.');
	return;
end
if ~MCC.get_redrawStatus()
    warning('MClust:Cutter', 'RedrawAxes is not checked.  Axes not aligned.');
    return
end
MCC.FocusOnAxes();
[xg,yg] = ginput(1);
mu = [xg, yg];
sigma0 = [50 0; 0 50];

% Calculate 100 steps
L = nan(100,1);
sigma = cell(100,1); sigma{1} = sigma0;
h = plot(xg, yg, 'r*');
for iC = 1:100;
    inCluster = find(det(sigma{iC}) * mvnpdf(X, mu, sigma{iC}) > thorn);
    if isempty(inCluster)
        sigma{iC+1} = sigma{iC}*sigmaStep;
    else
        if length(inCluster)<minSpikes
            sigma{iC+1} = sigma{iC}*sigmaStep;
        else
            sigma{iC+1} = cov([Xd(inCluster),Yd(inCluster)])*sigmaStep;
        end        
    end
end

% Slider to find sigma
D = figure('Name', 'slider to get sigma');
S = uicontrol('Style','slider', ...
    'Units', 'normalized','Position', [0.05 0.05 0.9 0.9], ...
    'callback', @sliderCallback, 'DeleteFcn', @closeSlider, ...
    'value', 1, 'min', 1, 'max', 100, 'ForegroundColor', 'r');


function sliderCallback(hObj, eventData, handles)
    if ishandle(h); delete(h); end
    v = floor(get(S, 'value'));
    inCluster = find(det(sigma{v}) * mvnpdf(X, mu, sigma{v}) > thorn);
    MCC.FocusOnAxes(); hold on;
    h = plot(Xd(inCluster), Yd(inCluster), 'ro');
end

function closeSlider(hObj, eventData, handles)
    if ishandle(h); delete(h); end
    self.AddSpikes(inCluster);
    MCC.RedrawAxes();
end

end

   
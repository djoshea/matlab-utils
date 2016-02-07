function ClusterFunc_RunKKwikOnCluster( self )
%
% ClusterFunc_RunKKwikOnCluster
%    Opens window and runs KlustaKwik on cluster

%================================================
% PARAMETERS
%================================================
minClusters = 2;
maxClusters = 7;

%================================================
% MAIN CODE
%================================================
MCS = MClust.GetSettings();
MCC = self.getAssociatedCutter();

MCC.StoreUndo(['KlustaKwik Cluster ' self.name]);

%================================================
% DRAW WINDOW
%================================================
RunKKwikFigureHandle = figure('Name','Run KlustaKwik', ...
    'Units', 'Normalized');
%-------------------------------
% Alignment variables

uicHeight = 0.04; uicWidth  = 0.25; 
dX = 0.3; XLocs = 0.1:dX:0.9;
dY = 0.04;
YLocs = 0.9:-dY:0.0;

% Create Feature Listboxes
FeatureListBoxes = MClustUtils.ListboxPair(RunKKwikFigureHandle, ...
    [XLocs(2) YLocs(9) 2*uicWidth 9*uicHeight], 'FeaturesToSkip', 'FeaturesToUse', ...
    'leftToolTip', 'Features that will NOT be included.', ...
    'rightToolTip', 'Features to be included in processing.');
FeatureListBoxes.SetLeftList(MCC.getFeatureNames());

uicontrol('Parent',RunKKwikFigureHandle, ...
	'Units', 'Normalized', ...
    'Position', [XLocs(1) + uicWidth/2 YLocs(1) uicWidth/2 uicHeight], ...
	'Style', 'text', 'String', self.name, ...
	'TooltipString', 'Starting cluster');	
Text_minClust = ...
    uicontrol('Parent',RunKKwikFigureHandle, ...
	'Units', 'Normalized', 'Position', [XLocs(1) + uicWidth/2 YLocs(2) uicWidth/2 uicHeight], ...
	'Style', 'edit', 'String', num2str(minClusters), ...
	'TooltipString', 'Mininum number of clusters');
Text_maxClust = ...
    uicontrol('Parent',RunKKwikFigureHandle, ...
	'Units', 'Normalized', 'Position', [XLocs(1) + uicWidth/2 YLocs(3) uicWidth/2 uicHeight], ...
	'Style', 'edit', 'String', num2str(7), ...
	'TooltipString', 'Maximum number of clusters');

uicontrol('Parent',RunKKwikFigureHandle, ...
	'Units', 'Normalized', 'Position', [XLocs(1) YLocs(1) uicWidth/2 uicHeight], ...
	'Style', 'text','String', 'Cluster');	
uicontrol('Parent',RunKKwikFigureHandle, ...
	'Units', 'Normalized', 'Position', [XLocs(1) YLocs(2) uicWidth/2 uicHeight], ...
	'Style', 'text','String', 'minClusters');	
uicontrol('Parent',RunKKwikFigureHandle, ...
	'Units', 'Normalized', 'Position', [XLocs(1) YLocs(3) uicWidth/2 uicHeight], ...
	'Style', 'text','String', 'maxClusters');	

uicontrol('Parent',RunKKwikFigureHandle, ...
	'Units', 'Normalized', 'Position', [XLocs(1) YLocs(20) uicWidth/2 uicHeight], ...
	'Style' ,'text', 'String', 'OtherParms');

Text_otherParms = ...
    uicontrol('Parent',RunKKwikFigureHandle, ...
	'Units', 'Normalized', 'Position', [XLocs(1)+uicWidth/2 YLocs(20) 0.9-uicWidth/2 uicHeight], ...
	'Style' ,'edit', 'String', '', 'HorizontalAlignment', 'Left',...
	'Tag', 'OtherParms', ...
	'TooltipString', 'Other parameters to pass to KlustaKwik');

uicontrol('Parent',RunKKwikFigureHandle, ...
	'Units', 'Normalized', 'Position', [XLocs(1) YLocs(22) uicWidth uicHeight*2], ...
	'Style', 'pushbutton', 'String', 'GO', 'Callback', @(src,event)RunKKwik(), ...
	'TooltipString', 'Accept features to use clustering the current cluster');

uicontrol('Parent',RunKKwikFigureHandle, ...
	'Units', 'Normalized', 'Position', [XLocs(1)+uicWidth YLocs(22) uicWidth uicHeight*2], ...
	'Style', 'pushbutton', 'String', 'CANCEL', 'Callback', @(src,event)close(RunKKwikFigureHandle));

%================================================
% CALLBACKS
%================================================
    function RunKKwik()
                
		S = self.GetSpikes();
		
        % calculate features
        featuresToUse = FeatureListBoxes.GetRightList();
        if isempty(featuresToUse) 
            return
		end
		
		% 2013-03-19 uses features from cutter and allows individual features 
		featureNames = MCC.getFeatureNames;
		features = {};
		for iF = 1:length(featuresToUse)
			ID = strmatch(featuresToUse(iF),featureNames);
			features = cat(1, features, MCC.Features(ID));
		end
        
        % write FET file
        fn = 'ClusterK'; FILEno = 1;
        [KKfn,~,nKKFeatures] = KlustaKwik.WriteKKwikFeatureFile(fn, features, ...
            'spikes', S);
        
        % parms
        minClusters = str2double(get(Text_minClust, 'String'));
        maxClusters = str2double(get(Text_maxClust, 'String'));
        otherParms = get(Text_otherParms, 'String');
        
        % GO!
        [KKoutput] = KlustaKwik.RunOneKKwik(KKfn, FILEno,...
            nKKFeatures, minClusters, maxClusters, ...
            'otherParms', otherParms);
        close(RunKKwikFigureHandle);
        
        % Read file
        A = dlmread(KKoutput, '%d');
        A = A(2:end);  % first line is number of classes found
        U = unique(A);
        nClu = length(U);
        for iC = 1:nClu
            C0 = MClust.ClusterTypes.SpikelistCluster();
            C0.name = [self.name '-KK' num2str(iC)];
            C0.color = MCS.colors(iC+1,:);
            C0.setAssociatedCutter(@MCC.GetCutter);
            C0.SetSpikes(S(A == U(iC)));
            MCC.Clusters{end+1} = C0;
        end

        % delete file
        delete(KKoutput);
        
        MCC.ReGo();
    end


end


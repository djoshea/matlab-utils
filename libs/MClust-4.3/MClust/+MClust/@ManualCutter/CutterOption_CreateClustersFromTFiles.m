function CutterOption_CreateClustersFromTFiles(self)

% find T files
[fn, fd] = uigetfile('*.t', 'T Files to get from', '*.t','MultiSelect', 'on');
if isempty(fn)
    return;
else
    if ~iscell(fn)
        fn = {fn};
    end
    self.StoreUndo('CreateClustersFromTFiles');
    
    % get timestamps
    MCD = MClust.GetData();
    T = MCD.FeatureTimestamps;

    % get .t files
    pushdir(fd);
    S = LoadSpikes(fn);
    popdir;
    for iC = 1:length(fn)        
        Sd = S{iC}.data;
        d = nan(size(Sd)); x = nan(size(Sd));
        for iS = 1:length(Sd); 
            [d(iS),x(iS)] = min(abs(T-Sd(iS))); 
            if any(d(iS) > 0.001)
                warning('MClust:CreateClustersFromTFiles',...
                    '%s: There are spike matches with >1ms errors. Proceed with caution.', ...
                    fn{iC});
            end            
        end
        
        C0 = MClust.ClusterTypes.SpikelistCluster();
        C0.name = fn{iC};
        C0.setAssociatedCutter(@self.GetCutter);
        C0.SetSpikes(x);
        self.Clusters{end+1} = C0;
        self.ReGo();
    end
end

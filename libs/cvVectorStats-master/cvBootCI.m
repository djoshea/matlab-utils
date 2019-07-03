function [ CI, bootStats ] = cvBootCI( fullDataStatistic, dataFun, dataCell, mode, alpha, nResamples )
    %This function uses the bootstrap to compute a confidence interval. 
    
    %fullDataStatistic is the statistic computed on the full, non-resampled
    %data.
    
    %dataFun is a handle to the function that computes the statistic of
    %interest.
    
    %dataCell is a cell vector that is input into dataFun. Data points are
    %resampled with replacement (row-wise) within each element of dataCell separately.
    %This ensures the same number of trials for each class of data. 
        
    bootStats = zeros(nResamples,numel(fullDataStatistic));
    for n=1:nResamples
        resampledCell = dataCell;
        for x=1:length(resampledCell)
            resampleIdx = randi(size(dataCell{x},1), size(dataCell{x},1), 1);
            resampledCell{x} = dataCell{x}(resampleIdx,:);
        end
        
        resampledStat = dataFun(resampledCell{:});
        bootStats(n,:) = resampledStat(:);
    end
        
    if strcmp(mode, 'bootCentered')
        cenStats = bootStats - mean(bootStats);
        cenStats = cenStats + fullDataStatistic;
        CI = prctile(cenStats, 100*[alpha/2, 1-alpha/2]);
    elseif strcmp(mode, 'bootPercentile')
        CI = prctile(bootStats, 100*[alpha/2, 1-alpha/2]);
    else
        error('Invalid mode, should be bootCentered or bootPercentile');
    end
end


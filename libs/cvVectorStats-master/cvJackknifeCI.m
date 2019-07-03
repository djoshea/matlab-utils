function [ CI, jackS ] = cvJackknifeCI( fullDataStatistic, dataFun, dataCell, alpha )
    %This function uses the jackknife to compute a confidence interval. 
    
    %fullDataStatistic is the statistic computed on all of the data.
    
    %dataFun is a handle to the function that computes the statistic of
    %interest
    
    %dataCell is a cell vector that is input into dataFun. Matching data points are
    %removed row-wise from dataCell to compute leave-one-out statistics for
    %the jackknife. 
            
    numObs = zeros(length(dataCell),1);
    for n=1:length(dataCell)
        numObs(n) = size(dataCell{n},1);
    end
    
    nFolds = min(numObs);
    foldIdx = getFoldedIdx(numObs, nFolds);

    jackS = zeros(nFolds,length(fullDataStatistic));
    for j=1:nFolds
        deleteCell = dataCell;
        for x=1:length(deleteCell)
            deleteCell{x}(foldIdx{x,j},:) = [];
        end
        jackS(j,:) = dataFun( deleteCell{:} );            
    end

    ps = nFolds*fullDataStatistic - (nFolds-1)*jackS;
    v = var(ps);
    
    multiplier = norminv((1-alpha/2), 0, 1);
    CI = [(fullDataStatistic - multiplier*sqrt(v/nFolds)); (fullDataStatistic + multiplier*sqrt(v/nFolds))];
end


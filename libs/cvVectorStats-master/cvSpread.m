function [ meanEuclidianDist, meanSquaredDist, CI, CIDistribution ] = cvSpread( obs, classIdx, CIMode, CIAlpha, CIResamples )
    %Estimates the average distance from the centroid of the mean vectors corresponding to each class.
    
    %obs is an N x D matrix, where N is the number of observations and D is
    %the number of dimensions. classIdx is an N x 1 vector describing, for
    %each observation, the class to which it belongs. 
        
    %CIMode can be none, bootCentered, bootPercentile, or jackknife
    
    %CIAlpha sets the coverage of the confidence interval to
    %100*(1-CIAlpha) percent
    
    %CIResamples sets the number of bootstrap resamples, if using bootstrap
    %mode (as opposed to jackknife)
    
    %CIDistribution is the distribution of bootstrap statistics or
    %jackknife leave-one-out statistics
    
    if nargin<3
        CIMode = 'none';
    end
    if nargin<4
        CIAlpha = 0.05;
    end
    if nargin<5
        CIResamples = 10000;
    end
    
    classList = unique(classIdx);
    nClasses = length(classList);
    nDim = size(obs,2);
    
    idxPerClass = cell(nClasses,1);
    obsPerClass = zeros(nClasses,1);
    for c=1:nClasses
        idxPerClass{c} = find(classIdx==classList(c));
        obsPerClass(c) = length(idxPerClass{c});
    end
    
    nFolds = min(obsPerClass);
    squaredDistEstimates = zeros(nFolds,nClasses);

    %split observations into folds
    foldIdxPerClass = getFoldedIdx(obsPerClass, nFolds);

    %for each fold, do the cross-validated spread computation
    for x=1:nFolds     
        bigSetIdx = cell(nClasses,1);
        smallSetIdx = cell(nClasses,1);

        allBigSetIdx = [];
        allSmallSetIdx = [];
        for c=1:nClasses
            idxPerFold = round(obsPerClass(c)/nFolds);

            smallSetIdx{c} = foldIdxPerClass{c,x};                
            bigSetIdx{c} = horzcat(foldIdxPerClass{c,[1:(x-1), (x+1):nFolds]});

            allBigSetIdx = [allBigSetIdx; idxPerClass{c}(bigSetIdx{c})];
            allSmallSetIdx = [allSmallSetIdx; idxPerClass{c}(smallSetIdx{c})];
        end

        centroid_smallSet = mean(obs(allSmallSetIdx,:));
        centroid_bigSet = mean(obs(allBigSetIdx,:));

        vec_smallSet = zeros(nClasses, nDim);
        vec_bigSet = zeros(nClasses, nDim);
        for c=1:nClasses
            vec_smallSet(c,:) = mean(obs(idxPerClass{c}(smallSetIdx{c}),:),1) - centroid_smallSet;
            vec_bigSet(c,:) = mean(obs(idxPerClass{c}(bigSetIdx{c}),:),1) - centroid_bigSet;
        end

        for c=1:nClasses
            squaredDistEstimates(x,c) = vec_bigSet(c,:)*vec_smallSet(c,:)';
        end
    end

    meanOfSquares = mean(squaredDistEstimates,1);
    medianUnbiasedEstimate = sign(meanOfSquares).*sqrt(abs(meanOfSquares));

    meanSquaredDist = mean(meanOfSquares);
    meanEuclidianDist = mean(medianUnbiasedEstimate);
    
    %compute confidence interval if requensted
    if ~strcmp(CIMode, 'none')
        classCell = cell(nClasses,1);
        for n=1:nClasses
            classCell{n} = obs(classIdx==classList(n),:);
        end
        
        [CI, CIDistribution] = cvCI([meanEuclidianDist, meanSquaredDist], @ciWrapper, classCell, CIMode, CIAlpha, CIResamples);
    else
        CI = [];
        CIDistribution = [];
    end
end

function output = ciWrapper(varargin)
    allObs = vertcat(varargin{:});
    allClassIdx = zeros(size(allObs,1),1);
    
    currIdx = 1;
    for x=1:length(varargin)
        allClassIdx(currIdx:(currIdx+size(varargin{x},1)-1)) = x;
        currIdx = currIdx + size(varargin{x},1);
    end
    
    [ medianUnbiasedEstimate, meanOfSquares ] = cvSpread( allObs, allClassIdx );
    output = [medianUnbiasedEstimate, meanOfSquares];
end


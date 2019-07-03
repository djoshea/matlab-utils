function [ euclideanDistance, squaredDistance, CI, CIDistribution ] = cvDistance( class1, class2, subtractMean, CIMode, CIAlpha, CIResamples )
    %This function estimates the distance between the means of two
    %distributions.

    %inputs:
    
    %class1 and class2 are N x D matrices, where D is the number of
    %dimensions and N is the number of samples
    
    %If class1 and class2 have different numbers of samples, this function
    %will use a slower method that considers all possible pairings from
    %each class for the held-out set
    
    %If subtractMean is true, this will center each vector
    %before computing the size of the difference (default is off).
    
    %CIMode can be none, bootCentered, bootPercentile, or jackknife
    
    %CIAlpha sets the coverage of the confidence interval to
    %100*(1-CIAlpha) percent
    
    %CIResamples sets the number of bootstrap resamples, if using bootstrap
    %mode (as opposed to jackknife)
    
    %CIDistribution is the distribution of bootstrap statistics or
    %jackknife leave-one-out statistics
    
    %outputs:
    
    %The first column of CI corresponds to euclidean distance, the second
    %column corresponds to squared distance. 
    
    %CIDistribution is the bootstrap distribution or leave-one-out
    %jackknife estimates

    if nargin<3
        subtractMean = false;
    end
    if nargin<4
        CIMode = 'none';
    end
    if nargin<5
        CIAlpha = 0.05;
    end
    if nargin<6
        CIResamples = 10000;
    end

    classSizes = [size(class1,1), size(class2,1)];
    
    if classSizes(1)==classSizes(2)
        %if class sizes are equal, run a special fast implementation
        squaredDistEstimates = zeros(size(class1,1),1);
        for x=1:size(class1,1)
            bigSetIdx = [1:(x-1),(x+1):size(class1,1)];
            smallSetIdx = x;

            meanDiff_bigSet = mean(class1(bigSetIdx,:)-class2(bigSetIdx,:));
            meanDiff_smallSet = class1(smallSetIdx,:)-class2(smallSetIdx,:);
            if subtractMean
                squaredDistEstimates(x) = (meanDiff_bigSet-mean(meanDiff_bigSet))*(meanDiff_smallSet-mean(meanDiff_smallSet))';
            else
                squaredDistEstimates(x) = meanDiff_bigSet*meanDiff_smallSet';
            end
        end
    else
        %if class sizes are unequal, we have to split the data into unequal
        %folds
        nFolds = min(classSizes);
        foldIdxPerClass = getFoldedIdx( classSizes, nFolds );

        squaredDistEstimates = zeros(nFolds,1);
        for x=1:nFolds
            bigSetIdx_1 = horzcat(foldIdxPerClass{1,[1:(x-1), (x+1):nFolds]});
            smallSetIdx_1 = foldIdxPerClass{1,x};

            bigSetIdx_2 = horzcat(foldIdxPerClass{2,[1:(x-1), (x+1):nFolds]});
            smallSetIdx_2 = foldIdxPerClass{2,x};

            meanDiff_bigSet = mean(class1(bigSetIdx_1,:),1) - mean(class2(bigSetIdx_2,:),1);
            meanDiff_smallSet = mean(class1(smallSetIdx_1,:),1)-mean(class2(smallSetIdx_2,:),1);
            if subtractMean
                squaredDistEstimates(x) = (meanDiff_bigSet-mean(meanDiff_bigSet))*(meanDiff_smallSet-mean(meanDiff_smallSet))';
            else
                squaredDistEstimates(x) = meanDiff_bigSet*meanDiff_smallSet';
            end
        end
    end
    
    squaredDistance = mean(squaredDistEstimates);
    euclideanDistance = sign(squaredDistance)*sqrt(abs(squaredDistance));
    
    %compute confidence interval if requensted
    if ~strcmp(CIMode, 'none')
        wrapperFun = @(x,y)(ciWrapper(x,y,subtractMean));
        [CI, CIDistribution] = cvCI([euclideanDistance, squaredDistance], wrapperFun, {class1, class2}, CIMode, CIAlpha, CIResamples);
    else
        CI = [];
        CIDistribution = [];
    end
end

function output = ciWrapper(class1, class2, subtractMean)
    [ euclideanDistance, squaredDistance ] = cvDistance( class1, class2, subtractMean );
    output = [euclideanDistance, squaredDistance];
end


function [ B, meanMagnitude, meanSquaredMagnitude, corrMat ] = cvOLS( predictors, response, nFolds, subtractMeans, transposeB )
    %This function estimates the magnitude of columns of linear model
    %coefficients, and the correlation between columns.

    %predictors is an N x D matrix of N samples and D dimensions
    
    %response is an N x R matrix of N samples and R dimensions
    
    %nFolds specifies how many cross-validation folds to use. each fold
    %must be big enough and the data must be ordered in a way such that
    %both the training set and the held out set for each fold contain
    %enough data to properly estimate the regression coefficients.
    
    %if subtractMeans is specified and is true, the function will subtract
    %the means of the coefficient vectors before estimating the squared
    %magnitude (this is useful for computing correlation coefficients)
    
    %if transposeB is specified and is true, the regression coefficients
    %will be transposed before computing the vector magnitudes. This is
    %useful if the rows of the coefficient matrix B are the vectors whose
    %size is of interest as opposed to the columns (default).
    
    if nargin<5
        transposeB = false;
    end
    if nargin<4
        subtractMeans = false;
    end
    
    %full sample estimate
    B = predictors\response;
    if transposeB
        B = B';
    end

    %split observations into folds
    heldOutIdx = cell(nFolds,1);
    minPerFold = floor(size(predictors,1)/nFolds);
    remainder = size(predictors,1)-minPerFold*nFolds;
    if remainder>0
        currIdx = 1:(minPerFold+1);
    else
        currIdx = 1:minPerFold;
    end
    for x=1:nFolds
        heldOutIdx{x} = currIdx;

        currIdx = currIdx + length(currIdx);
        if x==remainder
            currIdx(end)=[];
        end
    end
    
    %for each fold, fit the linear model separately on the training set and
    %the test set, then multiply the model coefficients together to
    %estimate squared values
    allCVEst = zeros(nFolds,size(B,2),size(B,2));
    for foldIdx=1:nFolds
        trainIdx = setdiff(1:size(predictors,1), heldOutIdx{foldIdx});

        B_train = predictors(trainIdx,:)\response(trainIdx,:);     
        B_heldOut = predictors(heldOutIdx{foldIdx},:)\response(heldOutIdx{foldIdx},:); 
        if transposeB
            B_train = B_train';
            B_heldOut = B_heldOut';
        end
        if subtractMeans
            B_train = B_train - mean(B_train);
            B_heldOut = B_heldOut - mean(B_heldOut);
        end
        
        allCVEst(foldIdx,:,:) = B_train'*B_heldOut;
    end
    
    %average fold-specific estimates together to get the magnitude of each
    %column
    meanSquaredMagnitude = diag(squeeze(mean(allCVEst,1)));
    meanMagnitude = sign(meanSquaredMagnitude).*sqrt(abs(meanSquaredMagnitude));
    
    %estimate the correlation between each column
    corrMat = zeros(length(meanSquaredMagnitude));
    for c1=1:length(meanSquaredMagnitude)
        for c2=1:length(meanSquaredMagnitude)
            corrMat(c1,c2) = (B(:,c1)-mean(B(:,c1)))'*(B(:,c2)-mean(B(:,c2)))/(meanMagnitude(c1)*meanMagnitude(c2));
        end
        corrMat(c1,c1) = 1;
    end
end


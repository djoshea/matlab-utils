function [ foldIdxPerClass ] = getFoldedIdx( obsPerClass, nFolds )
    %An internal function used to split data into folds for
    %cross-validation.
    
    %obsPerClass is a C x 1 vector containing the number of observations
    %for each of C classes
    
    %nFolds is an integer specifying the number of folds
    
    nClasses = length(obsPerClass);
    foldIdxPerClass = cell(nClasses,nFolds);
    for c=1:nClasses
        minPerFold = floor(obsPerClass(c)/nFolds);
        remainder = obsPerClass(c)-minPerFold*nFolds;

        if remainder>0
            currIdx = 1:(minPerFold+1);
        else
            currIdx = 1:minPerFold;
        end

        for x=1:nFolds
            foldIdxPerClass{c,x} = currIdx;

            currIdx = currIdx + length(currIdx);
            if x==remainder
                currIdx(end)=[];
            end
        end
    end
end


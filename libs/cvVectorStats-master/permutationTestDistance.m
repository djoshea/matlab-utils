function [ pValue, shuffleDistribution ] = permutationTestDistance( class1, class2, nResamples )
    %class1 and class2 are N x D matrices, where D is the number of
    %dimensions and N is the number of samples
    
    %nResamples specifies how many resamplings to perform
    
    allDat = [class1; class2];
    allGroups = [zeros(size(class1,1), 1); ones(size(class2,1),1)];
    [pValue, shuffleDistribution] = permutationTest(@(dat,groupClasses)(distanceWrapper(dat, groupClasses, false)), allDat, allGroups, nResamples, 'one-sided'); 
end

function dist = distanceWrapper(allDat, allGroups, subtractMean)
    class1 = allDat(allGroups==0,:);
    class2 = allDat(allGroups==1,:);
    [euclidianDistance, squaredDistance] = cvDistance(class1, class2, subtractMean);
    dist = [euclidianDistance, squaredDistance];
end
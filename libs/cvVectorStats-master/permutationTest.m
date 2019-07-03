function [ pValue, nullDistribution ] = permutationTest( fun, allDat, allGroups, nResamples, mode  )
    %An internal function for permutation testing. Returns the p-value and
    %null distribution.
    
    %fun is the test statistic function with two inputs: a matrix of
    %observations and a vector where each entry describes which
    %distribution that observation belongs to
    
    %allDat is an N x D matrix of observations, where N is the number of
    %observations and D is the number of dimensions
    
    %allGroups is an N x 1 vector describing which class ("group") the
    %observation belongs to
    
    %nResamples specifies how many resamplings to perform
    
    %mode can be one-sided or two-sided
    
    if nargin<5
        mode='one-sided';
    end
    
    unshuffledStatistic = fun(allDat, allGroups);
    nullDistribution = zeros(nResamples, length(unshuffledStatistic));
    
    for n=1:nResamples
        shuffIdx = randperm(length(allGroups));
        nullDistribution(n,:) = fun(allDat, allGroups(shuffIdx));
    end
           
    if strcmp(mode,'one-sided')
        [~,sortIdx] = sort(nullDistribution(:,1));
        nullDistribution = nullDistribution(sortIdx,:);
    
        pValue = zeros(length(unshuffledStatistic),1);
        for n=1:length(unshuffledStatistic)
            pIdx = find(nullDistribution(:,n)>unshuffledStatistic(n),1,'first');
            if isempty(pIdx)
                pValue(n) = 1/nResamples;
            else
                pValue(n) = (nResamples-pIdx)/nResamples;
            end
        end
    elseif strcmp(mode,'two-sided')
        [~,sortIdx] = sort(abs(nullDistribution(:,1)));
        nullDistribution = nullDistribution(sortIdx,:);
    
        pValue = zeros(length(unshuffledStatistic),1);
        for n=1:length(unshuffledStatistic)
            pIdx = find(abs(nullDistribution(:,n))>abs(unshuffledStatistic(n)),1,'first');
            if isempty(pIdx)
                pValue(n) = 1/nResamples;
            else
                pValue(n) = (nResamples-pIdx)/nResamples;
            end
        end        
    else
        error('Wrong mode, should be one-sided or two-sided');
    end
end


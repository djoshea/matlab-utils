function [ pValue, shuffleDistribution ] = permutationTestSpread( obs, classIdx, nResamples )
    %obs is an N x D matrix, where N is the number of observations and D is
    %the number of dimensions. classIdx is an N x 1 vector describing, for
    %each observation, the class to which it belongs. 
    
    %nResamples specifies how many resamplings to perform
    
    [pValue, shuffleDistribution] = permutationTest(@cvSpread, obs, classIdx, nResamples, 'one-sided'); 
end
function [ cvCorrEst, CI, CIDistribution ] = cvCorr( class1, class2, CIMode, CIAlpha, CIResamples )
    %class1 and class2 are N x D matrices, where D is the number of
    %dimensions and N is the number of samples
    
    %this function estimates the correlation between the mean vectors of
    %class1 and class2.
    
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
    
    unbiasedMag1 = cvDistance( class1, zeros(size(class1)), true );
    unbiasedMag2 = cvDistance( class2, zeros(size(class2)), true );

    mn1 = mean(class1);
    mn2 = mean(class2);
    cvCorrEst = (mn1-mean(mn1))*(mn2-mean(mn2))'/(unbiasedMag1*unbiasedMag2);
    
    %compute confidence interval if requensted    
    if ~strcmp(CIMode, 'none')
        wrapperFun = @(x,y)(cvCorr(x,y));
        [CI, CIDistribution] = cvCI(cvCorrEst, wrapperFun, {class1, class2}, CIMode, CIAlpha, CIResamples);
    else
        CI = [];
        CIDistribution = [];
    end
end
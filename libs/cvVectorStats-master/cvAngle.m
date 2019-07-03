function [ cvAngleEst, CI, CIDistribution ] = cvAngle( class1, class2, CIMode, CIAlpha, CIResamples )
    %class1 and class2 are N x D matrices, where D is the number of
    %dimensions and N is the number of samples
    
    %this function estimates the angle [cos(theta)] between the mean vectors of
    %class1 and class2.
    
    if nargin<3
        CIMode = 'none';
    end
    if nargin<4
        CIAlpha = 0.05;
    end
    if nargin<5
        CIResamples = 10000;
    end
    
    unbiasedMag1 = cvDistance( class1, zeros(size(class1)), false );
    unbiasedMag2 = cvDistance( class2, zeros(size(class2)), false );

    mn1 = mean(class1);
    mn2 = mean(class2);
    cvAngleEst = mn1*mn2'/(unbiasedMag1*unbiasedMag2);
    
    %compute confidence interval if requensted    
    if ~strcmp(CIMode, 'none')
        wrapperFun = @(x,y)(cvAngle(x,y));
        [CI, CIDistribution] = cvCI(cvAngleEst, wrapperFun, {class1, class2}, CIMode, CIAlpha, CIResamples);
    else
        CI = [];
        CIDistribution = [];
    end
end


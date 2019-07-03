function testCorr(plotDir, testCI)
    %%
    %The following samples data from two multivariate distributions whose mean vectors
    %have varying Pearson's correlation coefficients. Then, the correlation
    %is estimated using either the standard method or the cross-validated
    %method. 
    
    trialNums = [5, 20];
    nReps = 1000;
    corrVals = linspace(0,1,50);
    corrEst = zeros(length(trialNums),length(corrVals),nReps);
    corrEstUnbiased = zeros(length(trialNums),length(corrVals),nReps);
    nDim = 100;

    for t=1:length(trialNums)
        for corrIdx=1:length(corrVals)
            nTrials = trialNums(t);
            for n=1:nReps
                u1 = randn(1,nDim);
                u1 = u1 - mean(u1);
                u1 = u1 / norm(u1);

                u2 = randn(1,nDim);
                u2 = u2 - mean(u2);
                u2 = u2 - (u1*u2')*u1;
                u2 = u2 / norm(u2);
                u2 = u2*sqrt(1-corrVals(corrIdx)^2) + u1*corrVals(corrIdx);

                data1 = 5*u1+randn(nTrials,nDim);
                data2 = 5*u2+randn(nTrials,nDim);

                corrEst(t,corrIdx,n) = corr(mean(data1)', mean(data2)');

                corrEstUnbiased(t,corrIdx,n) = cvCorr(data1, data2);
            end
        end
    end

    %plot results
    statName = 'Correlation';
    plotTrueVsEstimated( trialNums, corrEst, corrEstUnbiased, corrVals, statName );
    saveas(gcf,[plotDir 'corrTrueVsEstimated.png'],'png');

    %%
    if testCI
        %The following samples data from two multivariate distributions whose mean vectors
        %have varying Pearson's correlation coefficients. Then, the correlation
        %is estimated and the confidence intervals is also estimated with 3 different techniques
        %and the coverage is verified. 
    
        nReps = 100;
        nDim = 100;
        corrVals = linspace(0,1,3);
        isCovered_cen = zeros(length(corrVals), nReps);
        isCovered_per = zeros(length(corrVals), nReps);
        isCovered_jac = zeros(length(corrVals), nReps);

        for corrIdx=1:length(corrVals)
            disp(corrIdx);
            nTrials = 20;
            for n=1:nReps
                u1 = randn(1,nDim);
                u1 = u1 - mean(u1);
                u1 = u1 / norm(u1);

                u2 = randn(1,nDim);
                u2 = u2 - mean(u2);
                u2 = u2 - (u1*u2')*u1;
                u2 = u2 / norm(u2);
                u2 = u2*sqrt(1-corrVals(corrIdx)^2) + u1*corrVals(corrIdx);

                data1 = 5*u1+randn(nTrials,nDim);
                data2 = 5*u2+randn(nTrials,nDim);

                [stat, CI] = cvCorr( data1, data2, 'bootCentered', 0.05, 1000 );
                isCovered_cen(corrIdx,n) = corrVals(corrIdx)>CI(1) & corrVals(corrIdx)<CI(2);

                [stat, CI] = cvCorr( data1, data2, 'bootPercentile', 0.05, 1000 );
                isCovered_per(corrIdx,n) = corrVals(corrIdx)>CI(1) & corrVals(corrIdx)<CI(2);

                [stat, CI] = cvCorr( data1, data2, 'jackknife', 0.05, 1000 );
                isCovered_jac(corrIdx,n) = corrVals(corrIdx)>CI(1) & corrVals(corrIdx)<CI(2);
            end
        end

        coverageCell = {isCovered_per, isCovered_cen, isCovered_jac};
        ciNames = {'Percentile Bootstrap','Centered Bootstrap','Jackknife'};
        plotCICoverage( ciNames, coverageCell, corrVals );
        saveas(gcf,[plotDir 'corrCICoverage.png'],'png');
    end
end
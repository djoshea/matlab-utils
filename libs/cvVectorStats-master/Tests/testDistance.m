function testDistance(plotDir, testCI, testPermTest)
    %%
    %The following samples data from two multivariate distributions whose mean vectors
    %have varying distances from each other. Then, the distance
    %is estimated using either the standard method or the cross-validated
    %method. 

    trialNums = [5, 20];
    nReps = 1000;
    distances = linspace(0,10,50);
    distanceEst = zeros(length(trialNums),length(distances),nReps);
    distanceEstUnbiased = zeros(length(trialNums),length(distances),nReps);
    nDim = 100;

    for t=1:length(trialNums)
        for distIdx=1:length(distances)
            nTrials = trialNums(t);
            for n=1:nReps
                data1 = randn(nTrials,nDim);
                data2 = (distances(distIdx)/sqrt(nDim)) + randn(nTrials,nDim);

                distanceEst(t,distIdx,n) = norm(mean(data1)-mean(data2));
                distanceEstUnbiased(t,distIdx,n) = cvDistance( data1, data2 );
            end
        end
    end

    statName = 'Distance';
    plotTrueVsEstimated( trialNums, distanceEst, distanceEstUnbiased, distances, statName );
    saveas(gcf,[plotDir 'distanceTrueVsEstimated.png'],'png');

    %%
    if testCI
        %The following samples data from two multivariate distributions whose mean vectors
        %have varying distances from each other. A confidence interval for
        %the distance is estimated using 3 different methods and the
        %coverage is checked. 
        
        nReps = 100;
        nDim = 100;
        distances = linspace(0,10,3);
        isCovered_cen = zeros(length(distances), nReps);
        isCovered_per = zeros(length(distances), nReps);
        isCovered_jac = zeros(length(distances), nReps);

        for distIdx=1:length(distances)
            disp(distIdx);
            for n=1:nReps
                data1 = randn(20,nDim);
                data2 = (distances(distIdx)/sqrt(nDim)) + randn(30,nDim);

                [stat, ~, CI] = cvDistance( data1, data2, false, 'bootCentered', 0.05, 1000 );
                isCovered_cen(distIdx,n) = distances(distIdx)>CI(1,1) & distances(distIdx)<CI(2,1);

                [stat, ~, CI] = cvDistance( data1, data2, false, 'bootPercentile', 0.05, 1000 );
                isCovered_per(distIdx,n) = distances(distIdx)>CI(1,1) & distances(distIdx)<CI(2,1);

                [stat, ~, CI] = cvDistance( data1, data2, false, 'jackknife', 0.05, 1000 );
                isCovered_jac(distIdx,n) = distances(distIdx)>CI(1,1) & distances(distIdx)<CI(2,1);
            end
        end

        coverageCell = {isCovered_per, isCovered_cen, isCovered_jac};
        ciNames = {'Percentile Bootstrap','Centered Bootstrap','Jackknife'};
        plotCICoverage( ciNames, coverageCell, distances );
        saveas(gcf,[plotDir 'distanceCICoverage.png'],'png');
    end
    
    %%
    if testPermTest
        %The following samples data from two multivariate distributions whose mean vectors
        %have varying distances from each other. The distance is estimated
        %using the cross-validated method and a p-value is estimated (for
        %testing whether the distance is >0). 
        
        nReps = 100;
        nDim = 100;
        distances = linspace(0,10,3);
        pValues = zeros(length(distances), nReps);

        for distIdx=1:length(distances)
            disp(distIdx);
            for n=1:nReps
                data1 = randn(20,nDim);
                data2 = (distances(distIdx)/sqrt(nDim)) + randn(30,nDim);

                pOut = permutationTestDistance( data1, data2, 1000 );
                pValues(distIdx, n) = pOut(1);
            end
        end

        sigCell = {pValues<0.05};
        sigNames = {'Permutation Test'};
        plotPermutationTestResults( sigNames, sigCell, distances );
        saveas(gcf,[plotDir 'distancePermTest.png'],'png');
    end
end

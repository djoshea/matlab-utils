function testSpread(plotDir, testCI, testPermTest)
    %%
    %The following samples data from eight multivariate distributions whose mean vectors
    %lie in a 2D ring. Then, the euclidean distance of each mean vector
    %from the centroid of all mean vectors is estimated with either the
    %cross-validated spread metric or the standard way. 
    
    nReps = 100;

    xAxis = linspace(-2,2,50);
    tuningProfile = normpdf(xAxis,0,1)';
    tuningProfile = tuningProfile - min(tuningProfile);
    tuningProfile = [zeros(20,1); tuningProfile; zeros(20,1)];
    nTimeBins = length(tuningProfile);

    theta = linspace(0,2*pi,9);
    theta = theta(1:8);

    trueSpread = zeros(length(nTimeBins),1);
    spreadEst = zeros(length(nTimeBins),nReps);
    spreadEstUnbiased = zeros(length(nTimeBins),nReps);
    nDim = 100;
    tuningVec = randn(nDim,2);

    for timeIdx=1:nTimeBins
        for n=1:nReps
            allData = [];
            allGroups = [];
            for conIdx=1:8
                if conIdx<=4
                    nTrials = 13;
                elseif conIdx==5
                    nTrials = 31;
                else
                    nTrials = 20;
                end
                signal = (tuningVec*[cos(theta(conIdx)); sin(theta(conIdx))])'*tuningProfile(timeIdx);
                allData = [allData; repmat(signal, nTrials, 1) + randn(nTrials,nDim)];
                allGroups = [allGroups; repmat(conIdx, nTrials, 1)];
            end

            allMN = zeros(8, nDim);
            for conIdx=1:8
                allMN(conIdx,:) = mean(allData(allGroups==conIdx,:));
            end
            centroid = mean(allMN);

            distFromCentroid = zeros(8,1);
            for conIdx=1:8
                distFromCentroid(conIdx) = norm(allMN(conIdx,:)-centroid);
            end

            spreadEst(timeIdx,n) = mean(distFromCentroid);
            spreadEstUnbiased(timeIdx,n) = cvSpread( allData, allGroups );
        end

        mnVectors = zeros(8,nDim);
        for conIdx=1:8
            mnVectors(conIdx,:) = tuningVec*[cos(theta(conIdx)); sin(theta(conIdx))]*tuningProfile(timeIdx);
        end

        centroid = mean(mnVectors);
        distFromCentroid = zeros(8,1);
        for conIdx=1:8
            distFromCentroid(conIdx) = norm(mnVectors(conIdx,:)-centroid);
        end

        trueSpread(timeIdx) = mean(distFromCentroid);
    end

    %%
    %plot results
    timeIdx = linspace(0,1,nTimeBins);

    colors = [0.8 0 0;
        0 0 0.8];
    lHandles = zeros(2,1);

    figure('Position',[680   838   659   260]);
    hold on;

    [mn,sd,CI] = normfit(spreadEst');
    [mn_un,sd_un,CI_un] = normfit(spreadEstUnbiased');

    lHandles(1)=plot(timeIdx, mn, 'Color', colors(1,:), 'LineWidth', 2);
    lHandles(2)=plot(timeIdx, mn_un, 'Color', colors(2,:), 'LineWidth', 2);
    lHandles(3)=plot(timeIdx,trueSpread,'--k','LineWidth',2);

    plot(timeIdx', [mn'-sd', mn'+sd'], 'Color', colors(1,:), 'LineStyle', '--');
    plot(timeIdx', [mn_un'-sd_un', mn_un'+sd_un'], 'Color', colors(2,:), 'LineStyle', '--');

    title(['20 Trials']);
    xlabel('Time');
    ylabel('Spread');

    legend(lHandles, {'Standard','Cross-Validated','True Spread'},'Box','Off');
    saveas(gcf,[plotDir 'spreadTrueVsEstimated.png'],'png');
    
    %%
    %The following samples data from eight multivariate distributions whose mean vectors
    %lie in a 2D ring. Then, the euclidean distance of each mean vector
    %from the centroid of all mean vectors is estimated, along with the
    %confidence interval (using 3 methods). The coverage of the confidence
    %intervals is verified. 

    if testCI
        nReps = 100;
        nDim = 100;
        tuningStrength = linspace(0,0.5,3);
        isCovered_cen = zeros(length(tuningStrength), nReps);
        isCovered_per = zeros(length(tuningStrength), nReps);
        isCovered_jac = zeros(length(tuningStrength), nReps);
        trueSpread = zeros(length(tuningStrength),1);

        for tuningIdx=1:length(tuningStrength)
            disp(tuningIdx);

            mnVectors = zeros(8,nDim);
            for conIdx=1:8
                mnVectors(conIdx,:) = tuningVec*[cos(theta(conIdx)); sin(theta(conIdx))]*tuningStrength(tuningIdx);
            end

            centroid = mean(mnVectors);
            distFromCentroid = zeros(8,1);
            for conIdx=1:8
                distFromCentroid(conIdx) = norm(mnVectors(conIdx,:)-centroid);
            end

            trueSpread(tuningIdx) = mean(distFromCentroid);

            for n=1:nReps
                allData = [];
                allGroups = [];
                for conIdx=1:8
                    if conIdx<=4
                        nTrials = 13;
                    elseif conIdx==5
                        nTrials = 31;
                    else
                        nTrials = 20;
                    end
                    signal = (tuningVec*[cos(theta(conIdx)); sin(theta(conIdx))])'*tuningStrength(tuningIdx);
                    allData = [allData; repmat(signal, nTrials, 1) + randn(nTrials,nDim)];
                    allGroups = [allGroups; repmat(conIdx, nTrials, 1)];
                end

                allMN = zeros(8, nDim);
                for conIdx=1:8
                    allMN(conIdx,:) = mean(allData(allGroups==conIdx,:));
                end
                centroid = mean(allMN);

                distFromCentroid = zeros(8,1);
                for conIdx=1:8
                    distFromCentroid(conIdx) = norm(allMN(conIdx,:)-centroid);
                end

                [stat, ~, CI] = cvSpread( allData, allGroups, 'bootCentered', 0.05, 1000 );
                isCovered_cen(tuningIdx,n) = trueSpread(tuningIdx)>CI(1,1) & trueSpread(tuningIdx)<CI(2,1);

                [stat, ~, CI] = cvSpread( allData, allGroups, 'bootPercentile', 0.05, 1000 );
                isCovered_per(tuningIdx,n) = trueSpread(tuningIdx)>CI(1,1) & trueSpread(tuningIdx)<CI(2,1);

                [stat, ~, CI] = cvSpread( allData, allGroups, 'jackknife', 0.05, 1000 );
                isCovered_jac(tuningIdx,n) = trueSpread(tuningIdx)>CI(1,1) & trueSpread(tuningIdx)<CI(2,1);
            end
        end

        coverageCell = {isCovered_per, isCovered_cen, isCovered_jac};
        ciNames = {'Percentile Bootstrap','Centered Bootstrap','Jackknife'};
        plotCICoverage( ciNames, coverageCell, trueSpread );
        saveas(gcf,[plotDir 'spreadCICoverage.png'],'png');
    end
    
    %%
    %The following samples data from eight multivariate distributions whose mean vectors
    %lie in a 2D ring. Then, the euclidean distance of each mean vector
    %from the centroid of all mean vectors is estimated, along with the
    %p-value using a permutation test. The # of significant (p<0.05) runs
    %is checked. 
    
    if testPermTest
        nReps = 100;
        nDim = 100;
        tuningStrength = linspace(0,0.5,3);
        pValues = zeros(length(tuningStrength), nReps);
        trueSpread = zeros(length(tuningStrength),1);

        for tuningIdx=1:length(tuningStrength)
            disp(tuningIdx);

            mnVectors = zeros(8,nDim);
            for conIdx=1:8
                mnVectors(conIdx,:) = tuningVec*[cos(theta(conIdx)); sin(theta(conIdx))]*tuningStrength(tuningIdx);
            end

            centroid = mean(mnVectors);
            distFromCentroid = zeros(8,1);
            for conIdx=1:8
                distFromCentroid(conIdx) = norm(mnVectors(conIdx,:)-centroid);
            end

            trueSpread(tuningIdx) = mean(distFromCentroid);

            for n=1:nReps
                allData = [];
                allGroups = [];
                for conIdx=1:8
                    if conIdx<=4
                        nTrials = 13;
                    elseif conIdx==5
                        nTrials = 31;
                    else
                        nTrials = 20;
                    end
                    signal = (tuningVec*[cos(theta(conIdx)); sin(theta(conIdx))])'*tuningStrength(tuningIdx);
                    allData = [allData; repmat(signal, nTrials, 1) + randn(nTrials,nDim)];
                    allGroups = [allGroups; repmat(conIdx, nTrials, 1)];
                end

                allMN = zeros(8, nDim);
                for conIdx=1:8
                    allMN(conIdx,:) = mean(allData(allGroups==conIdx,:));
                end
                centroid = mean(allMN);

                distFromCentroid = zeros(8,1);
                for conIdx=1:8
                    distFromCentroid(conIdx) = norm(allMN(conIdx,:)-centroid);
                end

                pValues(tuningIdx, n) = permutationTestSpread( allData, allGroups, 1000 );
            end
        end

        sigCell = {pValues<0.05};
        sigNames = {'Permutation Test'};
        plotPermutationTestResults( sigNames, sigCell, trueSpread );
        saveas(gcf,[plotDir 'spreadPermutationTest.png'],'png');
    end
end


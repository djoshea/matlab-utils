function testOLS(plotDir)
    %%
    %The following samples data from a linear model Y = beta * X. Then the
    %model (the beta coefficients) is fit and the magnitude and
    %correlation of the columns of beta are estimated using the
    %cross-validated metric or standard method. 
    
    %%
    %Magnitude.
    nReps = 1000;
    coefMag = linspace(0,3,50);
    coefMagEst = zeros(length(coefMag),nReps);
    coefMagEstUnbiased = zeros(length(coefMag),nReps);
    nDim = 100;

    for magIdx=1:length(coefMag)
        nTrials = 200;
        for n=1:nReps
            beta = randn(nDim,1);
            beta = (beta/norm(beta))*coefMag(magIdx);

            X = randn(1,nTrials);
            Y = (beta*X)';
            Y = Y + randn(size(Y));

            [ B, meanMagnitude, meanSquaredMagnitude, corrMat ] = cvOLS( X', Y, 10, false, true );

            coefMagEst(magIdx,n) = norm(B);
            coefMagEstUnbiased(magIdx,n) = meanMagnitude;
        end
    end

    statName = 'Magnitude';
    trialNums = 200;
    plotTrueVsEstimated( trialNums, coefMagEst, coefMagEstUnbiased, coefMag, statName )
    title('Coefficient Vector Magnitude');
    saveas(gcf,[plotDir 'olsMagTrueVsEstimated.png'],'png');
    
    %%
    %Correlation. 
    nReps = 1000;
    corrMag = linspace(0,1,50);
    corrMagEst = zeros(length(corrMag),nReps);
    corrMagEstUnbiased = zeros(length(corrMag),nReps);
    nDim = 100;

    for magIdx=1:length(corrMag)
        nTrials = 200;
        for n=1:nReps
            u1 = randn(1,nDim);
            u1 = u1 - mean(u1);
            u1 = u1 / norm(u1);

            u2 = randn(1,nDim);
            u2 = u2 - mean(u2);
            u2 = u2 - (u1*u2')*u1;
            u2 = u2 / norm(u2);
            u2 = u2*sqrt(1-corrMag(magIdx)^2) + u1*corrMag(magIdx);

            beta = [u1', u2'];
            X = randn(2,nTrials);
            Y = (beta*X)';
            Y = Y + randn(size(Y));

            [ B, meanMagnitude, meanSquaredMagnitude, corrMat ] = cvOLS( X', Y, 10, false, true );

            corrMagEst(magIdx,n) = corr(B(:,1), B(:,2));
            corrMagEstUnbiased(magIdx,n) = corrMat(1,2);
        end
    end

    statName = 'Correlation';
    trialNums = 200;
    plotTrueVsEstimated( trialNums, corrMagEst, corrMagEstUnbiased, corrMag, statName )
    title('Coefficient Vector Correlation');
    saveas(gcf,[plotDir 'olsCorrTrueVsEstimated.png'],'png');
end

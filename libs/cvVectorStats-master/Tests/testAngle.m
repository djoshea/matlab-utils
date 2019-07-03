function testAngle(plotDir)
    %%
    %The following samples data from two multivariate distributions whose mean vectors
    %have different angles. Then, the angle (cos[theta]) is estimated using either the standard method or the cross-validated
    %method. 
    
    trialNums = [5, 20];
    nReps = 1000;

    angleVals = linspace(0,pi,50);
    angleEst = zeros(length(trialNums),length(angleVals),nReps);
    angleEstUnbiased = zeros(length(trialNums),length(angleVals),nReps);
    trueVecAngle = zeros(length(trialNums),length(angleVals));
    nDim = 100;

    for t=1:length(trialNums)
        for angleIdx=1:length(angleVals)
            nTrials = trialNums(t);
            for n=1:nReps
                u1 = zeros(1,nDim);
                u1(1) = 1;

                u2 = zeros(1,nDim);
                u2(1:2) = [cos(angleVals(angleIdx)), sin(angleVals(angleIdx))];

                data1 = 5*u1+randn(nTrials,nDim)+0.5;
                data2 = 5*u2+randn(nTrials,nDim)+0.5;

                angleEst(t,angleIdx,n) = mean(data1)*mean(data2)'/(norm(mean(data2))*norm(mean(data1)));
                angleEstUnbiased(t,angleIdx,n) = cvAngle(data1, data2);

                v1 = 5*u1 + 0.5;
                v2 = 5*u2 + 0.5;
                trueVecAngle(t,angleIdx) = v1*v2'/(norm(v1)*norm(v2));
            end
        end
    end

    %%
    %plot results
    statName = 'Angle';
    plotTrueVsEstimated( trialNums, angleEst, angleEstUnbiased, trueVecAngle(1,:), statName );
    saveas(gcf,[plotDir 'angleTrueVsEstimated.png'],'png');
end

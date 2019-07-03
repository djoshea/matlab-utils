%%
%Cross-validated distance metric.

%First, we sample data from two multivariate normal distributions (data1 & data2). Then we
%call cvDistance to get an unbiased estimate of the euclidean distance and
%squared distance between these distributions, plus a confidence interval
%for these statistics. Finally, we call permutationTestDistance to get a
%p-value (for testing whether the distance is greater than 0) and null hypothesis distribution. 

nTrials = 20;
nDim = 100;

data1 = randn(nTrials,nDim);
data2 = 0.2 + randn(nTrials,nDim);

subtractMean = false;
CIMode = 'jackknife';
CIAlpha = 0.05;

[ euclideanDistance, squaredDistance, CI, CIDistribution ] = cvDistance( data1, data2, subtractMean, CIMode, CIAlpha );
[pValues, nullDistribution] = permutationTestDistance(data1, data2, 10000);
            
%%
%Cross-validated correlation metric.

%First, we sample data from two multivariate normal distributions (data1 & data2) whose 
%mean vectors have Pearson's correlation trueCorr. Then we
%call cvCorr to get an unbiased estimate of the correlation (plus a confidence interval). 

nTrials = 20;
nDim = 100;
trueCorr = 0.5;

u1 = randn(1,nDim);
u1 = u1 - mean(u1);
u1 = u1 / norm(u1);

u2 = randn(1,nDim);
u2 = u2 - mean(u2);
u2 = u2 - (u1*u2')*u1;
u2 = u2 / norm(u2);
u2 = u2*sqrt(1-trueCorr^2) + u1*trueCorr;

data1 = 5*u1+randn(nTrials,nDim);
data2 = 5*u2+randn(nTrials,nDim);

CIMode = 'jackknife';
CIAlpha = 0.05;

[ estimatedCorr, CI, CIDistribution ] = cvCorr( data1, data2, CIMode, CIAlpha );

%%
%Cross-validated vector angle metric.

%First, we sample data from two multivariate normal distributions (data1 & data2) whose 
%mean vectors have an angle [cos(theta)] of 0.5403. Then we
%call cvAngle to get an unbiased estimate of the angle (plus a confidence interval).

nTrials = 20;
nDim = 100;

u1 = zeros(1,nDim);
u1(1) = 1.0;

u2 = zeros(1,nDim);
u2(1:2) = [cos(1),sin(1)];

data1 = 5*u1+randn(nTrials,nDim);
data2 = 5*u2+randn(nTrials,nDim);

CIMode = 'jackknife';
CIAlpha = 0.05;

[ estimatedAngle, CI, CIDistribution ] = cvAngle( data1, data2, CIMode, CIAlpha );

%%
%Cross-validated multi-condition "spread" vector metric (average Euclidean
%distance from centroid).

%First, we generate data from 8 multivariate distributions whose means lie
%on a 2D ring with a radius of 3. We then call cvSpread to estimate the
%Euclidian distance from the centroid (should be 3) plus a confidence
%interval. 

nTrials = 20;
nDim = 100;

ringSubspace = randn(nDim,2);
ringSubspace = 3 * ringSubspace ./ [norm(ringSubspace(:,1)), norm(ringSubspace(:,2))];

theta = linspace(0,2*pi,9);
theta = theta(1:8);

allData = [];
allGroups = [];
for conIdx=1:8
    signal = (ringSubspace*[cos(theta(conIdx)); sin(theta(conIdx))])';
    allData = [allData; repmat(signal, nTrials, 1) + randn(nTrials,nDim)];
    allGroups = [allGroups; repmat(conIdx, nTrials, 1)];
end

CIMode = 'jackknife';
CIAlpha = 0.05;

[ estimatedEuclideanSpread, estimatedSquaredSpread, CI, CIDistribution ] = cvSpread( allData, allGroups, CIMode, CIAlpha );

%%
%Cross-validated ordinary least squares vector magnitude &
%correlation.

%First, we generate data from the linear model Y = beta * X.
%beta is an nDim x 3 matrix of linear model coefficients and X contains randomly
%generated inputs to the linear model. beta is constructed to have columns of magnitude 2, 4, and 6
%and for the first two columns to be positively corelated. 

%We then call cvOLS to estimate, without bias, the magnitude of the columns
%of beta and their correlations.

nDim = 100;
nTrials = 200;

beta = randn(nDim,3);
beta(:,2) = beta(:,2) + beta(:,1);
beta = (beta./[norm(beta(:,1)), norm(beta(:,2)), norm(beta(:,3))]).*[2 4 6];

X = randn(3,nTrials);
Y = (beta*X)';
Y = Y + randn(size(Y));

predictors = X';
response = Y;
nFolds = 10;
subtractMeans = false;
transposeB = true;

[ B, meanMagnitude, meanSquaredMagnitude, corrMat ] = cvOLS( predictors, response, nFolds, subtractMeans, transposeB );


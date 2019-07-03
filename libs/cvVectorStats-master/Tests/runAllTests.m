%Runs all tests that quantify performance of the cross-validated metrics
%vs. the standard estimates (completes in ~10 minutes). This script can also run tests that show the confidence
%intervals and permutation test p-values are reasonable (but these take a
%long time to run, maybe a few hours). Saves all plots to plotDir.

plotDir = '';
testCI = false;
testPermTest = false;

testDistance(plotDir, testCI, testPermTest);
testCorr(plotDir, testCI);
testAngle(plotDir);
testSpread(plotDir, testCI, testPermTest);
testOLS(plotDir);
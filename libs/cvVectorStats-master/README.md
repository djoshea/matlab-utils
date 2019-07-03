# Overview

cvVectorStats is a set of functions for using cross-validation to estimate Euclidean distances between the means of multivariate distributions (and for estimating other statistics that require Euclidean distance, such as Pearson's correlation). Using cross-validation substantially reduces bias and makes it possible to produce meaningful estimates of distance in the case of limited numbers of observations and/or low signal-to-noise regimes. 

Consider the case of estimating the distance between the means of two multivariate distributions A and B. One simple method is to first estimate the means of A and B by averaging observations from A and B, and then to compute the distance between these estimates. However, this method is upwardly biased; for example, if A and B have identical means, this method will always produce a value greater than zero. Cross-validation can overcome this problem in a straightforward way.

cvVectorStats was developed for analyzing neural recordings, which are high-dimensional and noisy, making it difficult to estimate distance accurately. For a more detailed explanation, see the paper "Hand Knob Area of Motor Cortex in People with Tetraplegia Represents the Whole Body in a Modular Way" (https://doi.org/10.1101/659839; methods section "Median-Unbiased Measurements of Firing Rate Distance"). I first became aware of the cross-validation technique from "Searchlight-based multi-voxel pattern analysis of fMRI by cross-validated MANOVA" (https://doi.org/10.1016/j.neuroimage.2013.11.043). 

# Features

Functions are included for computing the following statistics using cross-validation to substantially reduce or eliminate bias: Euclidean and squared distance between the means of two multivariate distributions (cvDistance), Pearson's correlation between the means of two multivariate distributions (cvCorr), vector angle between the means of two multivariate distributions (cvAngle), Euclidean norm and Pearson's correlation between groups of linear model coefficients (cvOLS), and the mean Euclidean distance of N multivariate distributions from the centroid of all N distributions (cvSpread; this metric can be used to tell how different a set of distributions are from each other).

Many of the functions can also produce confidence intervals using either bootstrapping or the jackknife. I've found that the percentile bootstrap method produces highly biased confidence intervals with these cross-validated metrics. I think this is because resampling the same observation multiple times upwardly biases the statistic when cross-validation is performed. The percentile method is included as an option ('bootstrapPercentile') only to validate and compare to other alternatives. Much better confidence intervals can be obtained by re-centering the bootstrap distribution on the test statistic ('bootstrapCentered'). However, I've found that an even better method for producing confidence intervals for these metrics is the jackknife, which is also included as an option ('jackknife'). I recommend using the jackknife method unless you have a reason to do otherwise.

Finally, a permutation test can be used for significance testing (for example, to test if the distance between the means of two distributions is greater than zero). Functions are provided for performing permutation tests for the distance metric (permutationTestDistance) and the cross-condition "spread" metric (permutationTestSpread).

# Example Usage

The script usageExamples.m has a simple example of how each function should be used - start here. 

# Test Scripts

The script runAllTests.m simulates each metric and compares it to the standard alternative, showing that the cross-validated metrics substantially reduce bias in all tested cases. It also has the option of checking the coverage of the confidence intervals and checking the permutation tests (although this takes a long time to run). 

# Details

- cvDistance and cvSpread give fully unbiased estimates of squared distance. However, to compute Euclidean distance, the square root function must be applied. This causes the metric to be biased (though it is still median-unbiased). The bias is slight and only occurs when the distances are very close to zero and/or the data is in a very low signal-to-noise regime (see Supplemental Figure 10 in https://doi.org/10.1101/659839). The bias causes the metric to be slightly conservative in these cases. Although squared distance is fully unbiased, I find Euclidean distance to be a much more useful metric, since it is easier to intuitively grasp its meaning.

- The cross-validated distance metrics can produce negative values, unlike standard estimates of distance. This is required for the metrics to be unbiased. It should be interpreted as evidence that the true distance is near zero. Negative values should only occur in low signal-to-noise regimes or when the true distance is small. Likewise, the cross-validated correlation metric can produce correlation values greater than 1 or less than -1. 

- In the original paper (https://doi.org/10.1101/659839), the equations are written for the case where each distribution has the same number of observations. The functions provided here also work for unequal numbers of observations. To do so, the data is split into N cross-validation folds, where N is the minimum number of observations across all distributions. Thus, each fold will take only one observation from the distribution with the smallest number of observations, but possibly more than one observation from the other distribution(s).




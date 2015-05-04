MatlabAUC
=========

Matlab functions for estimating receiver operating curves (ROC) and the area under the ROC curve (AUC), and various methods for estimating parametric and non-parametric confidence intervals for the AUC estimates. Also included is code for a simple bootstrap test for the estimated area under the ROC against a known value. The available CI estimation methods are:
* Hanley-McNeil, parametric [1]
* Mann-Whitney, non-parametric [2]
* Maximum variance, non-parametric [3]
* Logit, non-parametric [2]
* Bootstrap, non-parametric [2]
* Wald, non-parametric [4]
* Wald continuity-corrected, non-parametric [4]

The logit confidence interval estimator (default) has good coverage, is fairly robust to unbalanced samples and works for ordinal data [2,4]. Simulations show that the Wald intervals have more power for smaller sample sizes (<100 total samples), although these intervals are not robust to unbalanced data, nor do they work for ordinal data [4].

1.  Hanley, JA, McNeil, BJ (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143:29-36
2.  Qin, G, Hotilovac, L (2008). Comparison of non-parametric confidence intervals for the area under the ROC curve of a continuous-scale diagnostic test. Stat Meth Med Res, 17:207-21
3.  Cortex, C, Mohri, M (2004). Confidence intervals for the area under the ROC curve. NIPS Conference Proceedings
4.  Kottas, M, Kuss, O, Zapf A (2014). A modified Wald interval for the area under the ROC curve (AUC) in diagnostic case-control studies. BMC Medical Research Methodology 14:26.


## Instructions and example:
Install the functions under your Matlab path and have a look at `Testing/demo.m`. The following will get you started:

```
>> s = randn(50,1) + 1; n = randn(50,1); % simulate binormal model, "signal" and "noise"
% Estimate the AUC and calculate bootstrapped 95% confidence intervals (bias-corrected and accelerated)
>> [A,Aci] = auc(format_by_class(s,n),0.05,'boot',1000,'type','bca')
```
You can pass arguments through for different bootstrapping options, otherwise the default is a simple percentile bootstrap. This software depends on several functions from the Matlab Statistics toolbox (`norminv`, `tiedrank`, and `bootci`).

The following figure shows the results of some monte-carlo simulations exploring the different confidence interval estimators. Each set of colored data represents 1000 simulations for a different confidence interval estimator (simulation details follow the figure). The bootstrap and logit methods appear to have the best coverage for more extreme AUC values, tending to widen a bit closer to 0.5.

<img src="http://www.subcortex.net/research/code/area_under_roc_curve/auc-confidence-interval-comparison.png" alt="Drawing" style="width: 700px;" />

The simulations for each estimator are sorted according to the estimated AUC values (solid points), and plotted along with their 95% confidence intervals (thin colored lines). The x's indicate those data where the confidence interval did not cover the true AUC value (black line). Simulations were performed using a binormal model, with a sample size of 50 each for the signal and noise distributions. The noise samples were drawn from a standard normal distribution (mean=0, var=1), while the signal samples were drawn from a normal distribution with mean=0.75 (var=0.75; top row) or a normal distribution with mean=1.75 (var=1.75; bottom row). Bootstrap CIs were estimated using 500 resamples.

## Contributions
Copyright (c) 2014 Brian Lau [brian.lau@upmc.fr](mailto:brian.lau@upmc.fr), see [LICENSE](https://github.com/brian-lau/MatlabAUC/blob/master/LICENSE)


highdim
==========
A Matlab library for statistical testing of high-dimensional data, including
one and two-sample tests for homogeneity, uniformity, sphericity and
independence. Of note are implementations of some modern tests 
appropriate for data where dimensionality grows with samples size, possibly
exceeding the number of samples.

# Installation
Download [highdim](https://github.com/brian-lau/highdim/archive/master.zip) and 
add the resulting folder to your Matlab path. 
Folders prefixed by a `+` are packages that should not be explicitly added to your path, 
although their [parent folder should be](http://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html#brfynt_-3).

The Statistics toolbox is required.

# Examples
The various tests are most easily accessed through three interfaces: `DepTest1`, 
`DepTest2` and `UniSphereTest` for one-sample tests, two-sample tests and 
one-sample tests on the sphere, respectively.

Detailed simulations of size, power and comparisons between tests are available 
in the [wiki](https://github.com/brian-lau/highdim/wiki). The examples below 
give an idea of what's available.

### Multivariate (In)dependence, Sphericity and Homogeneity
```
% Independent, but non-spherical data
sigma = diag([ones(1,25),0.5*ones(1,5)]);
x = (sigma*randn(50,30)')';

% Independence tests (Han & Liu, 2014)
DepTest1(x,'test','spearman') 
DepTest1(x,'test','kendall') 

% Sphericity tests (Ledoit & Wolf, 2002; Wang & Yao, 2013; Zou et al., 2014)
DepTest1(x,'test','john')
DepTest1(x,'test','wang')
DepTest1(x,'test','sign')
DepTest1(x,'test','bcs')
```
* Han, F & Liu, H (2014). Distribution-free tests of independence with 
  applications to testing more structures. [arXiv:1410.4179](http://arxiv.org/abs/1410.4179)
* Ledoit, O & Wolf, M (2002). Some hypothesis tests for the covariance matrix
  when the dimension is large compared to the sample size. 
  [Annals of Statistics 30: 1081-1102](http://projecteuclid.org/euclid.aos/1031689018)
* Wang, Q & Yao, J (2013). On the sphericity test with large-dimensional
  observations. [Electronic Journal of Statistics 7: 2164-2192](http://projecteuclid.org/euclid.ejs/1378817880)
* Zou, C et al (2014). Multivariate sign-based high-dimensional tests for
  sphericity. [Biometrika 101: 229-236](http://biomet.oxfordjournals.org/content/101/1/229)

```
% Non-indepedent data, with ~0 correlation, from the same distribution
x = rand(200,1); y = rand(200,1);
xx = 0.5*(x+y)-0.5; yy = 0.5*(x-y);
corr(xx,yy)

% Two-sample Independence tests (Gretton et al, 2008; Szekely & Rizzo, 2013)
DepTest2(xx,yy,'test','dcorr') % Distance correlation t-test
DepTest2(xx,yy,'test','hsic') % Hilbert Schmidt Independence Criterion

% Do the samples come from the same distribution? (Gretton et al, 2012; Szekely et al. 2007)
DepTest2(xx,yy,'test','mmd') % Maximum mean discrepancy
DepTest2(xx,yy,'test','energy') % statistical energy
```
* Gretton, A et al (2008). A kernel statistical test of independence. [Neural Information Processing Systems](http://papers.nips.cc/paper/3201-a-kernel-statistical-test-of-independence.pdf)
* Gretton, A et al (2012). A kernel two-sample test. [Journal of Machine Learning Research 13: 723-773](http://www.jmlr.org/papers/volume13/gretton12a/gretton12a.pdf)
* Szekely, G et al (2007). Measuring and testing independence by correlation of distances. [Annals of Statistics 35: 2769-2794](http://projecteuclid.org/euclid.aos/1201012979)
* Szekely, G & Rizzo, M (2013). The distance correlation t-test of independence 
in high dimension. [Journal of Multivariate Analysis 117: 193-213](http://dx.doi.org/10.1016/j.jmva.2013.02.012)

```
% Independent data, different distributions
x = randn(200,1); y = rand(200,1);

% Two-sample Independence tests
DepTest2(x,y,'test','dcorr')
DepTest2(x,y,'test','hsic')

% Do the samples come from the same distribution?
DepTest2(x,y,'test','mmd')
DepTest2(x,y,'test','energy')
```
### Differences in multivariate means and covariances
```
% Two high-dimensional samples with sparse difference in covariance matrix (4 entries)
p = 50; n = 100;
for ii = 1:p
   for jj = 1:p
      sigma(ii,jj) = 0.5^abs(ii-jj);
   end
end
D = diag(unifrnd(0.5,2.5,p,1));
S = D^.5*sigma*D^.5; U = zeros(p,p);
[~,~,k] = utils.tri2sqind(p);
r = randperm(numel(k));
U(k(r(1:4))) = unifrnd(0,4,4,1)*max(diag(S));
U = U + U';
[~,da] = eig(S); [~,db] = eig(S+U);
d = abs(min([diag(da);diag(db)])) + 0.05;

x = mvnrnd(zeros(1,p),S+d*eye(p),n);
y = mvnrnd(zeros(1,p),S+U+d*(eye(p)),n);

DepTest2(x,y,'test','covdiff')

% Directly calling the test returns M, a matrix indicating where covariance 
% elements are significantly different (FWER controlled at alpha)
[pval,stat,M] = diff.covtest(x,y);
```
* Cai, T et al (2013). Two-sample covariance matrix testing and support
recovery in high-dimensional and sparse settings. [Journal of the
American Statistical Association 108: 265-277](http://www.tandfonline.com/doi/abs/10.1080/01621459.2012.758041)

### Uniformity on hypersphere
```
% Non-uniform samples, antipodally distributed on the sphere
sigma = diag([1 5 1]);
x = (sigma*randn(50,3)')';

% Is projection onto unit hypersphere uniformly distributed?
UniSphereTest(x,'test','rayleigh') % Rayleigh test fails since resultant is zero
UniSphereTest(x,'test','gine-ajne') % Weighted Gine-Ajne
UniSphereTest(x,'test','randproj') % random projection
UniSphereTest(x,'test','bingham') % Bingham
```
* Cai, T et al (2013). Distribution of angles in random packing on spheres. [Journal of Machine Learning Research 14: 1837-1864](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4196685/)
* Cuesta-Albertos, J et al (2009). On projection-based tests for 
directional and compositional data. [Statistics & Computing 19: 367-380](http://link.springer.com/article/10.1007%2Fs11222-008-9098-3#page-1)
* Gine, E (1975) Invariant tests for uniformity on compact Riemannian manifolds based on Sobolev norms. [Annals of Statistics 3: 1243-1266](http://www.jstor.org/discover/10.2307/2958247)
* Mardia, K & Jupp, P (2000). [Directional Statistics](https://books.google.fr/books?id=PTNiCm4Q-M0C&printsec=frontcover&source=gbs_ge_summary_r&cad=0#v=onepage&q&f=false). John Wiley
* Prentice, M (1978). On invariant tests of uniformity for directions
and orientations. [Annals of Statistics 6: 169-176](http://projecteuclid.org/euclid.aos/1176344075)

Contributions
--------------------------------
Copyright (c) 2017 Brian Lau [brian.lau@upmc.fr](mailto:brian.lau@upmc.fr), see [LICENSE](https://github.com/brian-lau/highdim/blob/master/LICENSE)

Please feel free to [fork](https://github.com/brian-lau/highdim/fork) and contribute!

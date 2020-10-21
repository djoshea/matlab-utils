%% Check the 95th percentiles of the statistics under uniformity

%% Gine & Bingham
clear all;
n = [10 30 50 100 150];
p = [10 20 30 40 50 100];
reps = 200;

tic;
for i = 1:numel(n)
   for j = 1:numel(p)
      for k = 1:reps
         x = randn(n(i),p(j));
         U = sphere.spatialSign(x);
         G(i,j,k) = sphere.gine(U);
         [~,B(i,j,k)] = sphere.bingham(U);
      end
      pctlG(i,j) = prctile(G(i,j,:),95);
      pctlB(i,j) = prctile(B(i,j,:),95);
   end
   toc
end

% Note that n,p refer to dim,samples in 
% Figueiredo & Gomes (2003). Power of Tests of Uniformity Defined on the 
%    Hypersphere. Communications in Statistics 32: 87-94
pB = ...
[71.249,  243.558, 514.535, NaN,     NaN,        NaN;...
 71.631,  243.709, 515.788, 885.647, NaN,        NaN;...
 72.040,  244.300, 515.409, 886.401, 1356.267,   5214.739;...
 NaN,     NaN,     NaN,     885.969, 1355.913,   5219.373;...
 NaN,     NaN,     NaN,     NaN,     1357.249,   5215.061];

pG = ...
[0.588,  0.543, 0.528, NaN,   NaN,     NaN;...
 0.590,  0.544, 0.529, 0.521, NaN,     NaN;...
 0.592,  0.544, 0.529, 0.521, 0.516,   0.508;...
 NaN,    NaN,     NaN, 0.521, 0.516,   0.508;...
 NaN,    NaN,     NaN, NaN,   0.517,   0.509];

pctlB-pB
pctlG-pG

%% Rayleigh & Anje
clear all;
n = [10 30 50 70 100 150];
p = [10 20 30 40 50 100];
reps = 500;

tic;
for i = 1:numel(n)
   for j = 1:numel(p)
      for k = 1:reps
         x = randn(n(i),p(j));
         U = sphere.spatialSign(x);
         [~,R(i,j,k)] = sphere.rayleigh(U);
         A(i,j,k) = sphere.ajne(U);
      end
      pctlR(i,j) = prctile(R(i,j,:),95);
      pctlA(i,j) = prctile(A(i,j,:),95);
   end
   toc
end

% Note that n,p refer to samples,dim in 
% Figueiredo (2007) Comparison of tests of uniformity defined on the 
%   hypersphere. Statistics & Probability Letters 77: 329-334
% 
pR = ...
[17.763, 30.694,  42.818,  54.723,  66.227,  122.647;...
 18.168, 31.193,  43.373,  55.625,  66.896,  124.296;...
 18.051, 31.305,  43.923,  55.631,  66.609,  124.318;...
 18.045, 31.317,  43.806,  55.820,  67.162,  123.986;...
 18.176, 31.195,  43.753,  55.557,  67.356,  123.091;...
 18.335, 31.511,  43.699,  55.551,  67.681,  124.109];

pA = ...
[0.379,  0.337,   0.319,   0.309,   0.302,   0.286;...
 0.387,  0.341,   0.322,   0.313,   0.304,   0.289;...
 0.385,  0.342,   0.325,   0.313,   0.303,   0.289;...
 0.384,  0.342,   0.324,   0.314,   0.305,   0.288;...
 0.387,  0.341,   0.324,   0.313,   0.306,   0.288;...
 0.390,  0.344,   0.324,   0.313,   0.307,   0.289];

pctlR-pR
pctlA-pA
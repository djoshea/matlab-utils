% pairsClusterTest from here: https://sites.google.com/site/antimatt/software
% randvonMisesFisherm from here: http://www.stat.pitt.edu/sungkyu/MiscPage.html
clear all;
n = 80;% 1000];
p = [4 8 16];%[4 10 20];
kappa = [0 0.25 0.5 1 2 4];%[0 1 2 4];
reps = 500;%2500;

prob_r = zeros(numel(kappa),numel(p));
prob_rp = zeros(numel(kappa),numel(p));
prob_b = zeros(numel(kappa),numel(p));
prob_g = zeros(numel(kappa),numel(p));
prob_a = zeros(numel(kappa),numel(p));
prob_ga = zeros(numel(kappa),numel(p));
prob_p = zeros(numel(kappa),numel(p));

test = UniSphereTest('autoRun',false);
test.params.nboot = 500;
tic;
for i = 1:numel(kappa)
   for j = 1:numel(p)
      for k = 1:reps
         x = sphere.vmfrnd(p(j),n,kappa(i))';
         
         % with noise
         %x = [randn(n,p(j)) ; sphere.vmfrnd(p(j),n,kappa(i))'];
         
% antipodally symmetric
%          mu = zeros(1,p(j));
%          mu(end) = 1;
%          x = [sphere.vmfrnd(p(j),n/2,kappa(i),mu)' ;...
%             sphere.vmfrnd(p(j),n/2,kappa(i),-mu)'];
% mixture of vmf
%          mu = zeros(1,p(j));
%          mu(end) = 1;
%          x = [sphere.vmfrnd(p(j),n/3,kappa(i),mu)' ;...
%             sphere.vmfrnd(p(j),n/3,kappa(i),-mu)' ;...
%             sphere.vmfrnd(p(j),n/3,kappa(i),rand(size(mu)))'];
         
         test.x = x;
         
         test.test = 'rayleigh'; test.run();
         h_r(k) = test.h;
         test.test = 'randproj'; test.run();
         h_rp(k) = test.h;
         test.test = 'bingham'; test.run();
         h_b(k) = test.h;
         test.test = 'gine'; test.run();
         h_g(k) = test.h;
         test.test = 'ajne'; test.run();
         h_a(k) = test.h;
         test.test = 'gine-ajne'; test.run();
         h_ga(k) = test.h;

         [clusteriness, temp, dists, k2] = pairsClusterTest(x);
         pv(k) = temp;

      end
      prob_r(i,j) = mean(h_r);
      prob_rp(i,j) = mean(h_rp);
      prob_b(i,j) = mean(h_b);
      prob_g(i,j) = mean(h_g);
      prob_a(i,j) = mean(h_a);
      prob_ga(i,j) = mean(h_ga);
      prob_p(i,j) = mean(pv<=0.05);
   end
   toc
   i
end

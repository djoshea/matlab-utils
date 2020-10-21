% Run some simulations to test the power of the test used by Raposo et al
% to detect non-uniform distributions on a hypersphere.

% You will need the highdim library here:

% as well as the following functions
% fdr_bh from here:
%    http://www.mathworks.com/matlabcentral/fileexchange/27418-benjamini---hochberg-yekutieli-procedure-for-controlling-false-discovery-rate
% pairsClusterTest from here: 
%    https://sites.google.com/site/antimatt/RaposoKaufmanChurchland2014.zip
% randvonMisesFisherm from here: 
%    http://www.stat.pitt.edu/sungkyu/software/randvonMisesFisherm.zip

n = 100; % sample size
p = [4 8 16 32]; % dimensionality
kappa = [0 1 2]; % von-Mises concentration, 0 is uniform for checking size
reps = 100; % repetitions of experiment

prob_r = zeros(numel(kappa),numel(p));
prob_rp = zeros(numel(kappa),numel(p));
prob_ga = zeros(numel(kappa),numel(p));
prob_p = zeros(numel(kappa),numel(p));

tic;
for i = 1:numel(kappa)
   for j = 1:numel(p)
      for k = 1:reps
         % Simple unimodal model
         x = randvonMisesFisherm(p(j),n,kappa(i))';
         
         pval_r(k) = uniSphereTest(x,'rayleigh');
         pval_rp(k) = uniSphereTest(x,'rp');
         pval_ga(k) = uniSphereTest(x,'ga');
         
         [clusteriness, temp, dists, k2] = pairsClusterTest(x);
         pval_p(k) = temp;

         % PCA reduce first?
%          [~, ~, latent] = princomp(x);
%          vaf = cumsum(latent)./sum(latent);
%          ind = find(vaf>=.9);
%          [clusteriness, temp, dists, k2] = pairsClusterTest(x(:,1:ind(1)));
%          pval_p(i,j,k) = temp;
      end
      prob_r(i,j) = mean(pval_r<0.05);
      prob_rp(i,j) = mean(pval_rp<0.05);
      prob_ga(i,j) = mean(pval_ga<0.05);
      prob_p(i,j) = mean(pval_p<0.05);
   end
   toc
end

figure; 
subplot(221); hold on
plot(kappa,prob_r,'--');
title('Rayleigh test');
legend('p=4','8','16','32')
axis([kappa(1) kappa(end) 0 1]);
subplot(222); hold on
plot(kappa,prob_r,'--');
plot(kappa,prob_ga);
title('Gine-Ajne test (solid)');
axis([kappa(1) kappa(end) 0 1]);
subplot(223); hold on
plot(kappa,prob_r,'--');
plot(kappa,prob_rp);
title('Random projection test (solid)');
axis([kappa(1) kappa(end) 0 1]);
subplot(224); hold on
plot(kappa,prob_r,'--');
plot(kappa,prob_p);
title('PAIRS test (solid)');
axis([kappa(1) kappa(end) 0 1]);


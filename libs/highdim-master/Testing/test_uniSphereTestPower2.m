% pairsClusterTest from here: https://sites.google.com/site/antimatt/software
% randvonMisesFisherm from here: http://www.stat.pitt.edu/sungkyu/MiscPage.html
clear all;
n = 60;
p = [4 8 16];%[4 10 20];
sigma = [1 10 20 40];%[0 1 2 4];
reps = 50;%2500;

prob_ga = zeros(numel(sigma),numel(p));
prob_p = zeros(numel(sigma),numel(p));

test = UniSphereTest('autoRun',false);
test.params.nboot = 500;
for i = 1:numel(sigma)
   for j = 1:numel(p)
      for k = 1:reps
         
         x = zeros(n,p(j));
         count = 0;
         for m = 1:p(j)
            S = eye(p(j));
            if (rand < 0.25) && (count <=6)
               S(m,m) = sigma(i);
               count = count + 1;
            end
            x = x + mvnrnd(zeros(1,p(j)),S,n);
         end

         test.x = x;
         
         test.test = 'gine-ajne'; test.run();
         h_ga(k) = test.h;

         [clusteriness, temp, dists, k2] = pairsClusterTest(x);
         pv(k) = temp;

      end
      prob_ga(i,j) = mean(h_ga);
      prob_p(i,j) = mean(pv<=0.05);
   end
   i
end

%% Compare bias-corrected sign test size & power with table 1 from
% Zou et al (2014). Multivariate sign-based high-dimensional tests for
%   sphericity. Biometrika 101: 229-236
clear all;
n = [40 80];
p = [55 181 642];
reps = 100;
v = [0 0.125 0.250];

tic;
for i = 1:numel(n)
   for j = 1:numel(p)
      for k = 1:numel(v)
         for m = 1:reps
            y = randn(n(i),p(j));
            vp = round(v(k)*p(j));
            A = [sqrt(2)*ones(vp,1) ; ones(p(j)-vp,1)];
            x = (diag(A)*y')';
            pval(m) = sphere.signtest(x,'test','bcs');
         end
         prob(i,j,k) = mean(pval<=0.05);
      end
      toc
   end
end

100*prob

% reps = 2000 % 24.11.2014
% approx = true
% ans(:,:,1) =
% 
%     4.7000    5.7500    5.8000
%     6.2500    3.9500    4.7000
% 
% ans(:,:,2) =
% 
%    45.1500   47.8500   49.9000
%    87.6500   93.3000   94.1500
% 
% ans(:,:,3) =
% 
%    64.7000   69.6500   72.4500
%    98.8000   99.3500   99.6500

% reps = 2000 % 25.11.2014
% approx = false
% ans(:,:,1) =
% 
%     5.8000    5.8000    5.9000
%     5.5500    5.1500    4.4000
% 
% ans(:,:,2) =
% 
%    43.9000   50.4500   50.4500
%    86.6000   92.8500   94.6500
% 
% ans(:,:,3) =
% 
%    67.2000   68.7000   71.8500
%    98.7500   99.6500   99.6000

% values from Zou et al. Table 1
pZ(:,:,1) = [...
4.9 4.9 5.1;...
4.7 5.2 5.1];
pZ(:,:,2) = [...
41 47 49;...
84 91 94];
pZ(:,:,3) = [...
64 68 72;...
99 100 100]

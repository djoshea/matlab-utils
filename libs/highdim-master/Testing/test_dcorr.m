
%% Table 1 from
%     Szekely & Rizzo (2013). The distance correlation t-test of independence 
%       in high dimension. J Multiv Analysis 117: 193-213
% Note that their table is a single sample
clear;
n = 30;
p = [1 2 4 8 16 32 64 128 256 512 1024 2048 4096];
reps = 1;

for i = 1:numel(p)
   for j = 1:reps
      x = rand(30,p(i));
      y = rand(30,p(i));
      r(j,i) = dep.dcorr(x,y);
      
      rstar(j,i) = dep.dcorr(x,y,true);
      T(j,i) = sqrt(n*(n-3)/2-1)*rstar(j,i)/sqrt(1-rstar(j,i)^2);
   end
end

table(p',mean(r,1)',mean(rstar,1)',mean(T,1)',...
   'VariableNames',{'pq','R','Rstar','T'})

% [pval,r,T] =dep.dcorrtest([1 2 3 4 5]',[1.4 1.4 3.5 4.2 4.8]')
% DepTest2([1 2 3 4 5]',[1.4 1.4 3.5 4.2 4.8]','test','dcorr')
% % Replicate using R 'energy' package
% dcor.ttest(c(1,2,3,4,5),c(1.4,1.4,3.5,4.2,4.8))
% 
% 	dcor t-test of independence
% 
% data:  c(1, 2, 3, 4, 5) and c(1.4, 1.4, 3.5, 4.2, 4.8)
% T = 5.6569, df = 4, p-value = 0.002406
% sample estimates:
% Bias corrected dcor 
%            0.942809 

% Section 3, example 1, page 200
clear;
n = 30;
p = 30;
q = 30;
reps = 1000;

for i = 1:reps
   x = rand(n,p);
   y = rand(n,q);
   [pval(i),~,T(i)] = dep.dcorrtest(x,y);
end

clear;
n = 30;
p = 30;
q = 30;
reps = 1000;

for i = 1:reps
   x = rand(n,p);
   y = x + sqrt(.2)*randn(n,q); % I think there is a typo in the paper
   [pval(i),~,T(i)] = dep.dcorrtest(x,y);
end
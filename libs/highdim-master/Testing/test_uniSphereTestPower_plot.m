load('/Users/brian/Dropbox/Temp/sphere/Testing/test_uniSphereTestPower_n80_1.mat');

prob_r1 = prob_r;
prob_ga1 = prob_ga;
prob_p1 = prob_p;

load('/Users/brian/Dropbox/Temp/sphere/Testing/test_uniSphereTestPower_n80_2.mat');

prob_r2 = prob_r;
prob_ga2 = prob_ga;
prob_p2 = prob_p;

prob_r = (prob_r1+prob_r2)/2;
prob_ga = (prob_ga1+prob_ga2)/2;
prob_p = (prob_p1+prob_p2)/2;


figure;
for i = 1:3
   subplot(3,1,i); hold on
   plot(kappa,prob_r(:,i),'-',kappa,prob_ga(:,i),'-',kappa,prob_p(:,i),'--');
%    plot(kappa,prob_ga(:,i),'--');
%    plot(kappa,prob_p(:,i),':');
   title(sprintf('dimension = %g',p(i)));
   if i == 1
      legend({'Rayleigh','Gine-Ajne','PAIRS'})
   end
end

ylabel('Empirical power')
xlabel('Kappa');
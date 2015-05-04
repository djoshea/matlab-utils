%----- Example from table 1 of Hanley & McNeil (1982)
y = [1*ones(33,1);1*ones(3,1) ; 2*ones(6,1);2*ones(2,1) ; ...
   3*ones(6,1);3*ones(2,1) ; 4*ones(11,1);4*ones(11,1) ; 5*ones(2,1);5*ones(33,1)];
t = [zeros(33,1);ones(3,1) ; zeros(6,1);ones(2,1) ; ...
   zeros(6,1);ones(2,1) ; zeros(11,1);ones(11,1) ; zeros(2,1);ones(33,1)];

[tp,fp] = roc([t,y]);

figure;
plot(fp,tp); axis square
xlabel('False alarm rate');
ylabel('Hit rate');

% Area under ROC curve and 95% confidence intervals
[A,Aci] = auc([t,y],0.05,'hanley')

% Bootstrap test of difference from 0.5
p = auc_bootstrap([t,y])

%----- Classic binormal example
% You may be more used to formatting the data as two vectors representing 
% the scores for each class
dp = randn(50,1) + 1;
dn = randn(50,1);

figure;
subplot(211);
hist(dp); title('Signal distribution');
axis([-4 4 get(gca,'ylim')])
subplot(212);
hist(dn); title('Noise distribution');
axis([-4 4 get(gca,'ylim')])

[tp,fp] = roc(format_by_class(dp,dn));

figure;
plot(fp,tp); axis square
xlabel('False alarm rate');
ylabel('Hit rate');

% Calling with 2 outputs without further inputs will generate bootstrapped 
% confidence intervals (95%)
% These default to simple percentile CIs
[A,Aci] = auc(format_by_class(dp,dn))
% You can also get parametric confidence intervals
[A,Aci] = auc(format_by_class(dp,dn),0.05,'hanley')
% Or a variety of non-parametric CIs
[A,Aci] = auc(format_by_class(dp,dn),0.05,'logit')
[A,Aci] = auc(format_by_class(dp,dn),0.05,'mann-whitney')
[A,Aci] = auc(format_by_class(dp,dn),0.05,'maxvar')
[A,Aci] = auc(format_by_class(dp,dn),0.05,'wald')
[A,Aci] = auc(format_by_class(dp,dn),0.05,'wald-cc')
% If you have the Statistics toolbox, you can pass additional arguments for fancier CIs
[A,Aci] = auc(format_by_class(dp,dn),0.05,'boot',1000,'type','bca')

% For the binormal case, we can calculate the true AUC analytically
trueA = normcdf(1/sqrt(1+1^2))

% We can test against this as a null hypothesis
p = auc_bootstrap(format_by_class(dp,dn),2000,'both',trueA)
% Or test against some other value
p = auc_bootstrap(format_by_class(dp,dn),2000,'both',0.5)

%----- Some Monte carlo simulations to get a feel for the estimators
alpha = 0.05;
nboot = 500;
nsamp = 50;
len = 50;

tic;
mu = norminv(.9)*sqrt(2);
sigma = 1;%sqrt(mu);
for i = 1:nsamp
   y = [sigma*randn(len,1)+mu ; randn(len,1)];
   t = [ones(len,1) ; zeros(len,1)];
   [A(i),Aci1(i,:)] = auc([t,y],alpha,'hanley');
   [~,Aci2(i,:)] = auc([t,y],alpha,'mann-whitney');
   [~,Aci3(i,:)] = auc([t,y],alpha,'maxvar');
   [~,Aci4(i,:)] = auc([t,y],alpha,'logit');
   [~,Aci5(i,:)] = auc([t,y],alpha,'boot',nboot,'type','bca');
   [~,Aci6(i,:)] = auc([t,y],alpha,'wald');
   [~,Aci7(i,:)] = auc([t,y],alpha,'wald-cc');
end
toc
trueA = normcdf(mu/sqrt(1+sigma^2));

% Plot
Aci = {Aci1 Aci2 Aci3 Aci4 Aci5 Aci6 Aci7};
figure;
for i = 1:numel(Aci)
   ind = (i-1)*nsamp + (1:nsamp) + (i-1)*100;
   
   subplot(211); hold on
   [sortA,I] = sort(A);
   sortCI = Aci{i}(I,:);
   
   plot(ind,sortA','.','markerfacecolor','k');
   ind2 = (trueA<sortCI(:,1)) | (trueA>sortCI(:,2));
   plot(ind(ind2),sortA(ind2)','x','markeredgecolor','r');
   plot(ind,sortCI(:,1),'-');
   plot(ind,sortCI(:,2),'-');
   text(ind(floor(nsamp/2)),1,sprintf('%1.3f',1-sum(ind2)/nsamp));
   
   subplot(212); hold on
   temp = Aci{i};
   LB = temp(:,1);
   temp = temp(:,2) - LB;
   tempA = A' - LB;
   [sortCILength,I] = sort(temp);
   sortCI = Aci{i}(I,:);
   sortA = tempA(I);

   plot(ind,sortA,'.','markerfacecolor','k');
   ind2 = (trueA<sortCI(:,1)) | (trueA>sortCI(:,2));
   plot(ind(ind2),sortA(ind2)','x','markeredgecolor','r');
   plot(ind,sortCILength(:,1),'-');
   text(ind(floor(nsamp/2)),.275,sprintf('%1.3f',mean(sortCILength)));
end

subplot(211); axis tight;
plot([1 ind(end)],[trueA trueA],'k-');
set(gca,'xtick',[],'tickdir','out');
subplot(212); axis tight;
set(gca,'xtick',[],'tickdir','out');

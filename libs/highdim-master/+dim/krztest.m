function [pval,stat,delta] = krztest(x,y,s)

nboot = 500;

[m,p] = size(x);
[n,q] = size(x);

[k,stat,delta,R] = dim.krzsim(x,y,s);
yR = y*R';

for i = 1:nboot
   ind = unidrnd(m,m,1);
   xb = x(ind,:);
   ind = unidrnd(n,n,1);
   yb = yR(ind,:);
   [~,Tm(i)] = dim.krzsim(xb,yb,s);
end
%hist(Tm);
pval = sum(Tm<=stat)/nboot;


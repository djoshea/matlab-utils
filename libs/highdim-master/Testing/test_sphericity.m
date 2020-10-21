% Zou et al (2014). Multivariate sign-based high-dimensional tests for
%   sphericity. Biometrika 101: 229-236

% bias-corrected sign test
% Check null distribution approximation
n = 1000;
p1 = zeros(n,1);
s1 = zeros(n,1);
p0 = zeros(n,1);
s0 = zeros(n,1);
for i = 1:n
   %x = randn(40,100);
   x = trnd(4,40,100);
   [p1(i),s1(i)] = sphere.signtest(x,'test','bcs','approx',false);
   [p0(i),s0(i)] = sphere.signtest(x,'test','bcs','approx',true);
end

figure;
dx = 0.1; xx = -3:dx:3;
n = histc(s0,xx);
subplot(211);hold on
bar(xx,n./sum(n),'histc');
plot(xx,normpdf(xx)*dx,'m');
title('normal approximation');
n = histc(s1,xx);
subplot(212);hold on
bar(xx,n./sum(n),'histc');
plot(xx,normpdf(xx)*dx,'m');
title('exact');

% Standard sign test
% Check null distribution approximation
n = 1000;
p = zeros(n,1);
s = zeros(n,1);
for i = 1:n
   x = randn(10,3);
   [p(i),s(i)] = sphere.signtest(x,'test','sign');
end

figure;
dx = 1; xx = 0:1:25;
n = histc(s,xx);
hold on
bar(xx,n./sum(n),'histc');
plot(xx,chi2pdf(xx,(3+2)*(3-1)/2)*dx,'m')

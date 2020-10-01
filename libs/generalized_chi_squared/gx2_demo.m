%% Generalized chi-squared demo
% look into each function code for more documentation

% gx2 parameters
lambda=[1 -10 2];
m=[1 2 3];
delta=[2 3 7];
sigma=5;
c=10;

% calculate mean and variance
[mu,v]=gx2stat(lambda,m,delta,sigma,c)

% calculate PDF and CDF at a point
x=25
f=gx2pdf(x,lambda,m,delta,sigma,c)
p=gx2cdf_davies(x,lambda,m,delta,sigma,c) % Davies' method (recommended)

% plot PDF and CDF
subplot(2,1,1); fplot(@(x) gx2pdf(x,lambda,m,delta,sigma,c))
xline(mu,'-',{'\mu \pm \sigma'},'labelorientation','horizontal');
xline(mu-sqrt(v),'-'); xline(mu+sqrt(v),'-');
xlim([mu-3*sqrt(v),mu+3*sqrt(v)]); ylim([0 .015]); ylabel 'PDF'

subplot(2,1,2); fplot(@(x) gx2cdf_davies(x,lambda,m,delta,sigma,c));
xline(mu,'-',{'\mu \pm \sigma'},'labelorientation','horizontal');
xline(mu-sqrt(v),'-'); xline(mu+sqrt(v),'-');
xlim([mu-3*sqrt(v),mu+3*sqrt(v)]); ylim([0 1]); xlabel x; ylabel 'CDF'  

% distribution of quadratic form of a normal variable

% normal parameters
mu=[1;2]; % mean
v=[2 1; 1 3]; % covariance matrix

% q(x)=(x1+x2)^2-x1-1 = [x1;x2]'*[1 1; 1 1]*[x1;x2] + [-1;0]'*[x1;x2] -1
quad.q2=[1 1; 1 1];
quad.q1=[-1;0];
quad.q0=-1;

% get gx2 parameters corr. to this quadratic form
[lambda,m,delta,sigma,c]=gx2_params_norm_quad(mu,v,quad)

% p(q(x)<3)
p=gx2cdf_davies(3,lambda,m,delta,sigma,c)

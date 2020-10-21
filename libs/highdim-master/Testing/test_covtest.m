% Check empirical size and power against table 1 from
%     Cai et al (2013). Two-sample covariance matrix testing and support
%       recovery in high-dimensional and sparse settings. Journal of the
%       American Statistical Association 108: 265-277

clear all;
p = 200;
n = 60;
model = 3;

for i = 1:500
   if model == 3
      sigma = zeros(p);
      for ii = 1:p
         for jj = 1:p
            if ii < jj
               if rand < 0.05
                  sigma(ii,jj) = 0.5;
               end
            end
         end
      end
      sigma = sigma + sigma';
      sigma = utils.putdiag(sigma,1);
      [~,ds] = eig(sigma);
      d = abs(min(diag(ds))) + 0.05;
      D = diag(unifrnd(0.5,2.5,p,1));
      S = sqrt(D)*((sigma+d*eye(p))/(1+d))*sqrt(D);
   elseif model == 2
      % Model 2
      for ii = 1:p
         for jj = 1:p
            sigma(ii,jj) = 0.5^abs(ii-jj);
         end
      end
      D = diag(unifrnd(0.5,2.5,p,1));
      S = D^.5*sigma*D^.5;
   elseif model == 4
      % Model 4
      for ii = 1:p
         for jj = 1:p
            delta(ii,jj) = (-1)^(ii+jj)*0.4^(abs(ii-jj)^(1/10));
         end
      end
      O = diag(unifrnd(1,5,p,1));
      S = O*delta*O;
   end
   U = zeros(p,p);
   [~,~,k] = utils.tri2sqind(p);
   r = randperm(numel(k));
   U(k(r(1:4))) = unifrnd(0,4,4,1)*max(diag(S));
   U = U + U';
   [~,da] = eig(S);
   [~,db] = eig(S+U);
   d = abs(min([diag(da);diag(db)])) + 0.05;
   
   S1 = S + d*eye(p);
   S2 = S + U + d*(eye(p));
   
   x = mvnrnd(zeros(1,p),S1,n);
   y = mvnrnd(zeros(1,p),S2,n);
   [pval(i),stat(i)] = diff.covtest(x,y);
end

%% Support recovery
% Not quite matching yet. I think this is due to a problem generating exactly
% the same covariance matrices as Cai et al. The off diagonal terms do not fall
% into the same range (pg 272 of paper). 
clear all;
p = 50;
n = 100;
model = 4;

if model == 3
   sigma = zeros(p);
   for ii = 1:p
      for jj = 1:p
         if ii < jj
            if rand < 0.05
               sigma(ii,jj) = 0.5;
            end
         end
      end
   end
   sigma = sigma + sigma';
   sigma = utils.putdiag(sigma,1);
   [~,ds] = eig(sigma);
   d = abs(min(diag(ds))) + 0.05;
   D = eye(p);
   S = D^.5*((sigma+d*eye(p))/(1+d))*D^.5;
elseif model == 2
   % Model 2
   for ii = 1:p
      for jj = 1:p
         sigma(ii,jj) = 0.5^abs(ii-jj);
      end
   end
   D = eye(p);
   S = D^.5*sigma*D^.5;
elseif model == 4
   % Model 4
   for ii = 1:p
      for jj = 1:p
         delta(ii,jj) = (-1)^(ii+jj)*0.4^(abs(ii-jj)^(1/10));
      end
   end
   O = eye(p);
   S = O*delta*O;
end
U = zeros(p,p);
[~,~,k] = utils.tri2sqind(p);
r = randperm(numel(k));
U(k(r(1:25))) = 2;
U = U + U';
[~,da] = eig(S);
[~,db] = eig(S+U);
d = abs(min([diag(da);diag(db)])) + 0.05;

S1 = (S + d*eye(p))/(1+d);
S2 = (S + U + d*(eye(p)))/(1+d);
sdiff = S2-S1;
min(sdiff(sdiff>0))
sd = (S2-S1)>0;
for i = 1:100  
   x = mvnrnd(zeros(1,p),S1,n);
   y = mvnrnd(zeros(1,p),S2,n);
   [pval(i),stat(i),Mthresh] = diff.covtest(x,y);
   temp = Mthresh & sd;
   s(i) = sum(temp(:))/sqrt(sum(Mthresh(:))*sum(sd(:)));
end

% Check aymptotic distribution
% figure;
% dx = 0.1; xx = -5:dx:25;
% n = histc(stat,xx);
% hold on
% plot(xx,cumsum(n)./sum(n));
% plot(xx,exp((-1/sqrt(8*pi))*exp(-xx/2)),'r')

%% Reproduce size and power from:
%     Han & Liu (2014). Distribution-free tests of independence with
%       applications to testing more structures. arXiv:1410.4179v1
% Table 1

% Model 1
n = [60 100];
p = [50 100 200 400 800];
reps = 10;

d = DepTest1();

tic;
for i = 1:numel(n)
   for j = 1:numel(p)
      for k = 1:reps
         x = randn(n(i),p(j));
         
         d.x = x;
         h(k) = d.h;
      end
      prob(i,j) = mean(h);
   end
   toc
end
% prob =
% 
%     0.0240    0.0110    0.0070    0.0060    0.0030
%     0.0230    0.0200    0.0180    0.0150    0.0050

% Model 5
n = [60 100];
p = [50 100 200 400 800];
reps = 100;

d = DepTest1();

tic;
for i = 1:numel(n)
   for j = 1:numel(p)
      for k = 1:reps
         dim = p(j);
         ind = triu(ones(dim,dim),1);
         f_ind = find(ind);
         r = randperm(numel(f_ind));
         nz = f_ind(r(1:4));
         t = zeros(dim,dim);
         t(nz) = rand(4,1);
         t = t + t';
         
         [~,D] = eig(eye(dim)+t);
         lambdamin = min(diag(D));
         delta = (-lambdamin+0.05)*(lambdamin<=0);
         R = eye(dim) + t + delta*eye(dim);
         
         x = mvnrnd(zeros(p(j),1),R,n(i));
         
         d.x = x;
         h(k) = d.h;
      end
      prob(i,j) = mean(h);
   end
   toc
end

% Model 7
n = [60 100];
p = [50 100 200 400 800];
reps = 100;

d = DepTest1();

tic;
for i = 1:numel(n)
   for j = 1:numel(p)
      for k = 1:reps
         dim = p(j);
         ind = triu(ones(dim,dim),1);
         f_ind = find(ind);
         r = randperm(numel(f_ind));
         nz = f_ind(r(1:4));
         t = zeros(dim,dim);
         t(nz) = rand(4,1);
         t = t + t';
         
         [~,D] = eig(eye(dim)+t);
         lambdamin = min(diag(D));
         delta = (-lambdamin+0.05)*(lambdamin<=0);
         R = eye(dim) + t + delta*eye(dim);
         
         x = mvnrnd(zeros(p(j),1),R,n(i));
         
         d.x = x.^3;
         h(k) = d.h;
      end
      prob(i,j) = mean(h);
   end
   toc
end

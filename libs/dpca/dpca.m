% DISCLAIMER
% ---------------------------------------------------------------------
% This work is released under the
%
% Creative Commons Attribution-NonCommercial 3.0 Unported (CC BY-NC 3.0)
%
% license. Therefore, you are free to copy, redistribute and remix
% the code. You may not use this work for commercial purposes (please 
% contact the authors at wieland.brendel@neuro.fchampalimaud.org).  
% You are obliged to reference the work of the original authors:
%
% Wieland Brendel & Christian Machens, published at NIPS 2011 "Demixed
% Principal Component Analysis", code@http://sourceforge.net/projects/dpca/
%
% USAGE AT YOUR OWN RISK! The authors may not be hold responsible for any
% kind of damages or losses of any kind that might be traced back to the
% usage or compilation of this work.
% ---------------------------------------------------------------------
    
function W = dpca(Y,comps,maxstep,tolerance)
    % Performs a DPCA analysis on the data set Y. For further information
    % on this method please check the paper
    %
    % http://books.nips.cc/papers/files/nips24/NIPS2011_1440.pdf
    %
    % or the manual/code at
    % 
    % http://sourceforge.net/projects/dpca/
    %
    % INPUT
    % -------
    %  Y: multidimensional array with the first index being the
    %  observed object (e.g. neuron number) and subsequent dimensions
    %  referring to different parameters. E.g. to access neuron 5 at time
    %  t=10 and stimulus=2 you write
    % 
    %  Y[5,10,2]
    %
    %  comps:   Number of latent dimensions (i.e. # of components)
    %  maxstep: maximum number of steps (default 250)
    %  tolerance: minimum relative change of the objective function
    %
    % RETURNS
    % -------
    %  W: loading matrix
    
    % load default parameters
    if isempty(tolerance), tolerance = 1d-6; end
    if isempty(maxstep), maxstep = 100; end
    
    % load covariance matrices    
    [covs, C] = dpca_covs(Y);
    covs = values(covs);
    
    % init loading matrix with PCA solution
    [W,D] = eigs(C,comps);
       
    % set parameters for line search
    t=1/4; a = 0.01/t;  % initial discount, step size & loop iterator
    old_L = L(W,covs);
    steps = 0;
    xchange = 1;
    
    while steps < maxstep && xchange > tolerance
        Q = W;
        for k=1:size(W,2)
            w = W(:,k);
            g = Lgrad(w,covs,C);
            W(:,k) = W(:,k) + a*g;
        end
        
        W = qn(W);
        new_L = L(W,covs);
        xchange = (new_L - old_L)/new_L;
        
        % check if step-size was too large
        if old_L > new_L
            disp('Readjust step-size')
            a = a*t;
            W = Q;
            xchange = 1;
        end
        
        old_L = new_L;
        steps = steps + 1;
        disp(['iteration ', num2str(i), ' @ objective ', num2str(new_L)])
    end
    
    function l = L(W,covs)
        % evaluate loss function
        l = 0;
        for kk=1:size(W,2)
            wb = W(:,kk)/norm(W(:,kk));
            x = X2(wb,covs);
            l = l + norm(x)^2/norm(x,1);
        end
    end

    function gw = Lgrad(w,covs,S)
        % return gradient of loss function
        gw = zeros(size(w));     
        
        for j=1:length(covs)
           gw = gw + grad_C(w,covs(j),S);
        end
        
        function gwC = grad_C(w,C,S)
            Cv = cell2mat(C)*w;
            Sv = S*w;
            varC = w.'*Cv;
            varS = w.'*Sv;
            
            gwC = 2*varC/varS*Cv - (varC/varS)^2*Sv;
        end
    end

    function x = X2(wp,covs)
        % return a vector x with components x_i = w.'*C_i*w
        wp = wp/norm(wp);
        x = cellfun(@(C) wp.'*C*wp, covs);
    end

    function W = qn(W)
        % symmetric orthogonalization
        W = W/norm(W);
        N = size(W,2);
        while norm(W.'*W - eye(N)) > 0.0000000001
           W = 3/2*W - 1/2*W*W.'*W;
        end       
    end  

end

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

function [covmats, C] = dpca_covs(Y)
	%  Calculates the marginalized covariance matrices for DPCA
    %  
    %  INPUT
    %  -----
    %  Y: multidimensional array with the first index being the
    %  observed object (e.g. neuron number) and subsequent dimensions
    %  referring to different parameters. E.g. to access neuron 5 at time
    %  t=10 and stimulus=2 you write
    % 
    %  Y[5,10,2]
    %
    %  RETURNS
    %  -------
    %  covs: array of covariance matrices
    %  C : full covariance matrix

    % remean Y
    Y = bsxfun(@minus,Y,mmean(Y,2:ndims(Y)));
    
    % flag for using memory efficient version (NOT IMPLEMENTED YET!)
%     if (nargin < 2), memflag = false; end
    memflag = false;
    
    if ~memflag
        % collect averages beforehand
        map_Y = containers.Map();
        % use mat2str to convert array of dimensions to string (to use as
        % key). Inverse function A = eval(mat2str(A)).
        set = subsets(2:ndims(Y));
        for k=1:length(set)
          map_Y(mat2str(set{k})) = mmean(Y,set{k});
        end
    end
    
    % COVARIANCE MATRICES
    sets = subsets(2:ndims(Y),false);
    covmats = containers.Map();
    for set=sets
        set = cell2mat(set);
        mY = marg_aver(Y,set);
        mY = reshape(mY,size(Y,1),[]);
        covmats(mat2str(set)) =  mY*mY.'/size(mY,2);
    end
       
    % PCA COVARIANCE MATRIX
    cY = reshape(Y,size(Y,1),[]);
    cY = bsxfun(@minus,cY,mean(cY,2));
    C = cY*cY.'/size(cY,2);
    
    function idims = indinv(ndim,dims)
        % returns the inverse of dims (for a given shape)
        idims = 2:ndim;
        idims(dims-1) = [];
    end

    function set = subsets(iterable,emptyset)
       % powerset([1,2,3]) --> () (1,) (2,) (3,) (1,2) (1,3) (2,3) (1,2,3)
       if (nargin < 2), emptyset = true; end  % flag for including the empty set
       set = {};
       j = 1;
 
       if (emptyset), start = 0; else start = 1; end
       
       for k=start:length(iterable)
           combs = combnk(iterable,k);
           for i=1:size(combs,1)
             set{j} = combs(i,:);
             j = j + 1;
           end
       end   
    end

    function A = mmean(A,axis)
       % takes mean of A over axis = list of axes
%        axis
       for ax=1:length(axis)
           A = mean(A,axis(ax));
       end
    end

    function marY = marg_aver(Y,dims)
        idims = indinv(ndims(Y),dims);       % inv dimensions S\phi
        tset = subsets(dims,false);         % subsets of phi
        marY = mmean(Y,idims);
        for t=tset
            t = cell2mat(t);
            if rem(length(t),2) == 0
                marY = bsxfun(@plus,marY,mmean(Y,cat(2,idims,t)));
            else
                marY = bsxfun(@minus,marY,mmean(Y,cat(2,idims,t)));
            end
        end
    end
end